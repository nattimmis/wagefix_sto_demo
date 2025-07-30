import React, { useState } from 'react';
import { View, Button, Text, Image } from 'react-native';
import * as ImagePicker from 'expo-image-picker';

export default function OnboardScreen() {
  const [passport, setPassport] = useState(null);
  const [selfie, setSelfie] = useState(null);
  const [status, setStatus] = useState('');

  const pickImage = async (setter) => {
    const result = await ImagePicker.launchImageLibraryAsync({ base64: false });
    if (!result.canceled) {
      setter(result.assets[0]);
    }
  };

  const upload = async () => {
    if (!passport || !selfie) {
      setStatus("Please select both files");
      return;
    }

    const formData = new FormData();
    formData.append('passport', {
      uri: passport.uri,
      name: 'passport.jpg',
      type: 'image/jpeg'
    });
    formData.append('selfie', {
      uri: selfie.uri,
      name: 'selfie.jpg',
      type: 'image/jpeg'
    });

    try {
      const res = await fetch('http://<your-ip>:8000/kyc_check', {
        method: 'POST',
        headers: { 'Content-Type': 'multipart/form-data' },
