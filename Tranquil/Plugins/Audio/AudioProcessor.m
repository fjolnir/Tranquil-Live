#import "AudioProcessor.h"
#import <Accelerate/Accelerate.h>
#import <pthread.h>

@interface AudioProcessor () {
	PaDeviceIndex _device;
	PaStream *_inputStream;
	
	// The audio sample buffer
	void *_sampleBuffer;
	pthread_mutex_t _sampleBufferMutex;
	
	// Buffers for the fft
	float *_hannWindow;
	float *_hannWindowedBuffer;
	DSPSplitComplex _splitBuffer;
	FFTSetup _fftSetup;
	int _fftSize, _fftSizeOver2;
	
	// The output from the fft
	float *_magnitudes;
	// Averaged slices of _magnitudes corresponding to _numberOfFrequencyBands
	float *_frequencyBands;
	int _numberOfFrequencyBands;
}
- (int)_processInput:(const void *)buffer
	 framesPerBuffer:(unsigned long)framesPerBuffer 
			timeInfo:(const PaStreamCallbackTimeInfo *)timeInfo
		 statusFlags:(PaStreamCallbackFlags)statusFlags;
- (void)_updateSpectrum;
@end

static int inputCallback(const void *inputBuffer, void *outputBuffer,
						 unsigned long framesPerBuffer,
						 const PaStreamCallbackTimeInfo* timeInfo,
						 PaStreamCallbackFlags statusFlags,
						 void *userData )
{
	return [(AudioProcessor *)userData _processInput:inputBuffer
									  framesPerBuffer:framesPerBuffer
											 timeInfo:timeInfo
										  statusFlags:statusFlags];
}

@implementation AudioProcessor

@synthesize isRunning=_isRunning, frequencyBands=_frequencyBands, numberOfFrequencyBands=_numberOfFrequencyBands, gain=_gain, smoothingBias=_smoothingBias;

+ (PaDeviceIndex)deviceIndexForName:(NSString *)aName
{
	for(int i = 0; i < Pa_GetDeviceCount(); ++i) {
		const PaDeviceInfo *info = Pa_GetDeviceInfo(i);
		if([aName isEqualToString:[NSString stringWithUTF8String:info->name]])
			return i;
	}
	return paNoDevice;
}

- (id)initWithDevice:(PaDeviceIndex)aDevice
{
	if(aDevice == paNoDevice) return nil;
	
	self = [super init];
	if(!self) return nil;
	
	[self setNumberOfFrequencyBands:16];
	_gain = 1.0;
	_smoothingBias = 0.8;
	
	// Prepare the fourier transform
	_fftSize = 1024;
	_fftSizeOver2 = _fftSize/2;
	_hannWindow = (float *)malloc(sizeof(float) * _fftSize);
	vDSP_hann_window(_hannWindow, _fftSize, vDSP_HANN_DENORM);
	_hannWindowedBuffer = (float *)malloc(sizeof(float)*_fftSize);

	_splitBuffer.realp = (float *)malloc(sizeof(float)*_fftSizeOver2);
	_splitBuffer.imagp = (float *)malloc(sizeof(float)*_fftSizeOver2);
	
	float log2n = log2f(_fftSize);
	_fftSetup = vDSP_create_fftsetup(log2n, FFT_RADIX2);
	_magnitudes = calloc(_fftSizeOver2, sizeof(float));
	assert(_fftSetup);
	
	
	// Create the audio stream
	_isRunning = NO;
	_device = aDevice;
	
	PaError err;
	PaStreamParameters inputParameters;
	inputParameters.device = _device;
	inputParameters.channelCount = 1; // We just need mono
	inputParameters.sampleFormat = paFloat32;
	inputParameters.suggestedLatency = Pa_GetDeviceInfo(_device)->defaultLowInputLatency;
	inputParameters.hostApiSpecificStreamInfo = NULL;
	
	float sampleRate = 44100;
	float framesPerBuffer = 1024;
	pthread_mutex_init(&_sampleBufferMutex, NULL);
	_sampleBuffer = (float *)malloc(sizeof(float)*framesPerBuffer);
	err = Pa_OpenStream(&_inputStream, &inputParameters, NULL, sampleRate, framesPerBuffer, paNoFlag, inputCallback, self);
	assert(err == paNoError);
	
	return self;
}

- (void)finalize
{
	Pa_CloseStream(_inputStream);
	free(_sampleBuffer);
	pthread_mutex_destroy(&_sampleBufferMutex);
	free(_hannWindow);
	free(_hannWindowedBuffer);
	vDSP_destroy_fftsetup(_fftSetup);
	free(_magnitudes);
	free(_frequencyBands);
	
	[super finalize];
}

- (void)start
{
	if(!_isRunning) {
		_isRunning = YES;
		assert(Pa_StartStream(_inputStream) == paNoError);
	}
}
- (void)stop
{
	if(_isRunning) {
		_isRunning = NO;
		assert(Pa_StopStream(_inputStream) == paNoError);
	}
}

- (float)magnitudeForBand:(int)aBand
{
	return _frequencyBands[aBand % _numberOfFrequencyBands];
}

- (void)update
{
	[self _updateSpectrum];
	
	for(int i = 0; i < _numberOfFrequencyBands; ++i) {
		int from = (int)( ((float)i/(float)_numberOfFrequencyBands) * _fftSizeOver2 );
		int to = (int)( ((float)(i+1)/(float)_numberOfFrequencyBands) * _fftSizeOver2 );
		float value = 0.0;
		for(int j = from; j <= to && j < _fftSizeOver2; ++j) {
			value += _magnitudes[j];
		}
		if(value != NAN && value != INFINITY && value != negativeInfinity) { // These values would kill all future ones
			value *= _gain;
			//_frequencyBands[i] = value;
			_frequencyBands[i] = (_smoothingBias * _frequencyBands[i]) + ((1.0 - _smoothingBias) * value);
		}
	}
}

- (void)_updateSpectrum
{
	pthread_mutex_lock(&_sampleBufferMutex);
	
	// Apply hann window
	vDSP_vmul(_sampleBuffer, 1, _hannWindow, 1, _hannWindowedBuffer, 1, _fftSize);
	pthread_mutex_unlock(&_sampleBufferMutex);
	
	// Convert to split complex format with evens in real and odds in imaginary
	vDSP_ctoz((COMPLEX *)_hannWindowedBuffer, 2, &_splitBuffer, 1, _fftSizeOver2);
	
	// Calculate the fft
	vDSP_fft_zrip(_fftSetup, &_splitBuffer, 1, log2(_fftSize), FFT_FORWARD);
	
	// Convert to decibels
	float mags[_fftSizeOver2];
	vDSP_zvmags(&_splitBuffer, 1, mags, 1, _fftSizeOver2);
	float zero = 1.0;
	vDSP_vdbcon(mags, 1, &zero, _magnitudes, 1, _fftSizeOver2, 0);
}

- (int)_processInput:(const void *)buffer
	 framesPerBuffer:(unsigned long)framesPerBuffer 
			timeInfo:(const PaStreamCallbackTimeInfo *)timeInfo
		 statusFlags:(PaStreamCallbackFlags)statusFlags
{
	// Update the buffer if it isn't being processed
	if(_isRunning && pthread_mutex_trylock(&_sampleBufferMutex) == 0) {
		memcpy(_sampleBuffer, buffer, sizeof(float)*framesPerBuffer);
		pthread_mutex_unlock(&_sampleBufferMutex);
	}
	return paContinue;
}

- (void)setNumberOfFrequencyBands:(int)aNumberOfrequencyBands
{
	_numberOfFrequencyBands = aNumberOfrequencyBands;
	if(_frequencyBands)
		_frequencyBands = calloc(_numberOfFrequencyBands, sizeof(float));
	else {
		_frequencyBands = realloc(_frequencyBands, sizeof(float)*_numberOfFrequencyBands);
		memset(_frequencyBands, 0, sizeof(float)*_numberOfFrequencyBands);
	}
}
@end
