import React, { useState, useEffect } from 'react';
import { Button, Text, View, NativeModules } from 'react-native';
import AudioRecord from 'react-native-audio-record';
import { check, PERMISSIONS, request } from 'react-native-permissions';

const App = () => {
  const [result, setResult] = useState('');
  const [startTime, setStartTime] = useState(0);
  const { InferenceModule } = NativeModules;

  useEffect(() => {
    const options = {
      sampleRate: 16000,
      channels: 1,
      bitsPerSample: 16,
      audioSource: 6,
      wavFile: 'test.wav'
    };

    AudioRecord.init(options);
  }, []);

  const startRecording = async () => {
    const permission = await check(PERMISSIONS.IOS.MICROPHONE);
    if (permission !== 'granted') {
      await request(PERMISSIONS.IOS.MICROPHONE);
    }
    setStartTime(new Date().getTime()); // Record the start time
    AudioRecord.start();
  };

  const stopRecording = async () => {
    const audioFilePath = await AudioRecord.stop();
    const endTime = new Date().getTime();
    const durationInSeconds = (endTime - startTime) / 1000;
    InferenceModule.recognizeFromFilePath(audioFilePath, durationInSeconds, (error: any, inferenceResult: React.SetStateAction<string>) => {
      if (error) {
        console.error(error);
        return;
      }
      setResult(inferenceResult);
    });
  };

  return (
    <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
      <Button title="Start Recording" onPress={startRecording} />
      <Button title="Stop Recording" onPress={stopRecording} />
      <Text>{result}</Text>
    </View>
  );
};

export default App;
