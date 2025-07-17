/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 */

import React, { useEffect, useState } from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';
import firebase from '@react-native-firebase/app';
import auth from '@react-native-firebase/auth';
import { View, Text, Button, StyleSheet, Alert } from 'react-native';
import { GoogleSignin } from '@react-native-google-signin/google-signin';
import type { NativeStackScreenProps } from '@react-navigation/native-stack';

GoogleSignin.configure({
  webClientId: 'YOUR_WEB_CLIENT_ID',
});

type RootStackParamList = {
  Login: undefined;
  Chat: undefined;
};

type LoginScreenProps = NativeStackScreenProps<RootStackParamList, 'Login'>;

const Stack = createStackNavigator<RootStackParamList>();

function LoginScreen({ navigation }: LoginScreenProps) {
  const [initializing, setInitializing] = useState(true);
  const [user, setUser] = useState<firebase.UserInfo | null>(null);

  useEffect(() => {
    const subscriber = auth().onAuthStateChanged(onAuthStateChanged);
    return subscriber; // unsubscribe on unmount
  }, []);

  function onAuthStateChanged(user: firebase.UserInfo | null) {
    setUser(user);
    if (initializing) setInitializing(false);
  }

  async function googleSignIn() {
    try {
      await GoogleSignin.hasPlayServices({
        showPlayServicesUpdateDialog: true,
      });
      const userInfo = await GoogleSignin.signIn();
      const idToken = userInfo.idToken;
      const googleCredential =
        firebase.auth.GoogleAuthProvider.credential(idToken);
      await auth().signInWithCredential(googleCredential);
    } catch (error: any) {
      Alert.alert('Google Signin Error', error.message);
      console.error(error);
    }
  }

  if (!user) {
    return (
      <View>
        <Text>Login</Text>
        <Button title="Google Sign-In" onPress={() => googleSignIn()} />
      </View>
    );
  }

  return (
    <View>
      <Text>Welcome {user.email}</Text>
      <Button title="Go to Chat" onPress={() => navigation.navigate('Chat')} />
    </View>
  );
}

function ChatScreen() {
  return (
    <View>
      <Text>Chat Screen</Text>
    </View>
  );
}

function App() {
  return (
    <NavigationContainer>
      <Stack.Navigator>
        <Stack.Screen name="Login" component={LoginScreen} />
        <Stack.Screen name="Chat" component={ChatScreen} />
      </Stack.Navigator>
    </NavigationContainer>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
});

export default App;
