#import "TAudioProcessor.h"
#import <Accelerate/Accelerate.h>
#import <pthread.h>

@interface TAudioProcessor () {
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
	float *_magnitutes;
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
	return [(TAudioProcessor *)userData _processInput:inputBuffer
									  framesPerBuffer:framesPerBuffer
											 timeInfo:timeInfo
										  statusFlags:statusFlags];
}
@implementation TAudioProcessor

@synthesize isRunning=_isRunning, frequencyBands=_frequencyBands, numberOfFrequencyBands=_numberOfFrequencyBands, gain=_gain, smoothingBias=_smoothingBias;


- (id)initWithDevice:(PaDeviceIndex)aDevice
{
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
	if(_fftSetup == NULL) NSLog(@"Couldn't allocate memory for FFT");
	
	
	// Create the audio stream
	_isRunning = NO;
	_device = aDevice;
	
	PaError err;
	PaStreamParameters inputParameters;
	inputParameters.device = _device;
	inputParameters.channelCount = 1;
	inputParameters.sampleFormat = paFloat32;
	inputParameters.suggestedLatency = Pa_GetDeviceInfo(_device)->defaultLowInputLatency;
	inputParameters.hostApiSpecificStreamInfo = NULL;
	
	float sampleRate = 44100;
	float framesPerBuffer = 1024;
	pthread_mutex_init(&_sampleBufferMutex, NULL);
	_sampleBuffer = (float *)malloc(sizeof(float)*framesPerBuffer);
	err = Pa_OpenStream(&_inputStream, &inputParameters, NULL, sampleRate, framesPerBuffer, paClipOff, inputCallback, self);
	assert(err == paNoError);
	
	return self;
}

- (void)start
{
	if(!_isRunning) {
		PaError err;
		_isRunning = YES;
		err = Pa_StartStream(_inputStream);
		assert(err == paNoError);
	}
}
- (void)stop
{
	if(_isRunning) {
		_isRunning = NO;
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
		int from = (int)( (i/_numberOfFrequencyBands) * _fftSize );
		int to = (int)( ((i+1)/_numberOfFrequencyBands) * _fftSize );
		float value = 0.0;
		for(int j = from; j <= to && j < _fftSize; ++j) {
			value += _magnitutes[j];
		}
		value *= _gain;
		_frequencyBands[i] = (_smoothingBias * _frequencyBands[i]) + ((1.0 - _smoothingBias) * value);
	}
}

- (void)_updateSpectrum
{
	pthread_mutex_lock(&_sampleBufferMutex);
	
	// Apply hann window
	vDSP_vmul(_sampleBuffer, 1, _hannWindow, 1, _hannWindowedBuffer, 1, _fftSize);
	// Convert to split complex format with evens in real and odds in imaginary
	vDSP_ctoz((COMPLEX *)_hannWindowedBuffer, 2, &_splitBuffer, 1, _fftSize/2);
	
	// Calculate the fft
	vDSP_fft_zrip(_fftSetup, &_splitBuffer, 1, log2(_fftSize), FFT_FORWARD);
	_splitBuffer.imagp[0] = 0.0;
	
	pthread_mutex_unlock(&_sampleBufferMutex);
	
	float magnitudes[_fftSizeOver2];
	//float phases[_fftSizeOver2];;
	for(int i = 0; i < _fftSizeOver2; ++i) {
		float power = _splitBuffer.realp[i]*_splitBuffer.realp[i] + _splitBuffer.imagp[i]*_splitBuffer.imagp[i];
		magnitudes[i] = sqrtf(power);
		// phases[i] = atan2f(_splitBuffer.imagp[i], _splitBuffer.realp[i]);
	}
}

- (int)_processInput:(const void *)buffer
	 framesPerBuffer:(unsigned long)framesPerBuffer 
			timeInfo:(const PaStreamCallbackTimeInfo *)timeInfo
		 statusFlags:(PaStreamCallbackFlags)statusFlags
{
	// Update the buffer if it isn't being processed
	if(pthread_mutex_trylock(&_sampleBufferMutex) == 0) {
		memcpy(_sampleBuffer, buffer, sizeof(float)*framesPerBuffer);
		pthread_mutex_unlock(&_sampleBufferMutex);
	}
	return paContinue;
}

- (void)setNumberOfFrequencyBands:(int)aNumberOfrequencyBands
{
	_numberOfFrequencyBands = aNumberOfrequencyBands;
	if(_frequencyBands)
		_frequencyBands = malloc(sizeof(float)*_numberOfFrequencyBands);
	else
		_frequencyBands = realloc(_frequencyBands, sizeof(float)*_numberOfFrequencyBands);
}
@end
