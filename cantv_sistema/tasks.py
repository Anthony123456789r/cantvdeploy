from background_task import background
#=============LIBRERIAS PARA EL BOT=============
import pyttsx3
import speech_recognition as sr
import pywhatkit
import AVMSpeechMath as sm
import wikipedia
import datetime
import webbrowser
import time
import pyjokes
import chistesESP as c
import random
import subprocess
#========================================================

@background(schedule=0)
def speak_text(text):
    iniciar = pyttsx3.init()
    voices = iniciar.getProperty("voices")
    velocidad = 180
    iniciar.setProperty("voice", voices[0].id)
    iniciar.setProperty("rate", velocidad)
    iniciar.say(text)
    iniciar.runAndWait()
