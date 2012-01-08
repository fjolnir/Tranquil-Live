-- Called at the end of each frame (beginning of the next)

_errorDuringUserCallback = false
_prevUserFrameCallback = nil
_userFrameCallback = nil

function _frameCallback()
	_audio_updateSpectrum()
	if not pcall(_userFrameCallback) then
		_errorDuringUserCallback = true
		pcall(_prevUserFrameCallback)
	else
		_errorDuringUserCallback = false
	end
end

function everyFrame(aCallback)
	if not _errorDuringUserCallback then
		_prevUserFrameCallback = _userFrameCallback
	end
	_userFrameCallback = aCallback
end