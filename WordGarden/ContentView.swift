//
//  ContentView.swift
//  WordGarden
//
//  Created by Francesca MACDONALD on 2023-08-21.
//

import SwiftUI
import AVFAudio

struct ContentView: View {
    @State private var wordsGuessed = 0
    @State private var wordsMissed = 0
    @State private var  gameStatusMessage = "How many guesses to uncover the hidden word?"
    @State private var guessedLetter = ""
    @State private var currentWordIndex = 0
    @State private var imageName = "flower8"
    @State private var playAgain = true
    @FocusState private var textFieldIsFocused
    @State private var wordToGuess = ""
    @State private var lettersGuessed = ""
    @State private var revealedWord = ""
    @State private var guessesRemaining = 0
    @State private var playAgainButtonLabel = "Another Word?"
    @State private var audioPlayer: AVAudioPlayer!
    
    private let wordsToGuess = ["SWIFT", "DOG", "CAT", "FRANCESCA"]
    private let maximumGuesses = 8
    
    var body: some View {
        VStack {
            HStack {
                VStack (alignment: .leading)
                {
                Text("Words Guessed: \(wordsGuessed)")
                Text("Words Missed: \(wordsMissed)")
                }
                Spacer()
                VStack (alignment: .leading)
                {
                Text("Words to Guess: \(wordsToGuess.count - (wordsMissed + wordsGuessed))")
                Text("Words in Game: \(wordsToGuess.count)")
                }
            }
            .padding()
            Spacer()
            Text(gameStatusMessage)
                .font(.title)
                .multilineTextAlignment(.center)
                .frame(height: 80)
                .minimumScaleFactor(0.5)
                .padding()
            Text(revealedWord)
                .font(.title)
            if playAgain {
                HStack {
                    TextField("", text: $guessedLetter)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 30)
                        .overlay {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.gray, lineWidth: 2)
                            
                        }
                        .keyboardType(.asciiCapable)
                        .submitLabel(.done)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.characters)
                        .onChange(of: guessedLetter) { _ in
                            guessedLetter = guessedLetter.trimmingCharacters(in: .letters.inverted)
                            guard let lastChar = guessedLetter.last else {
                                return
                            }
                            
                            guessedLetter = String(lastChar).uppercased()
                        }
                        .focused($textFieldIsFocused)
                        .onSubmit {
                            guard guessedLetter != "" else {
                                return
                            }
                            guessALetter()
                        }
                    Button("Guess a Letter") {
                        guessALetter()
                    }
                    .buttonStyle(.bordered)
                    .tint(.mint)
                    .disabled(guessedLetter.isEmpty)
                }
            } else {
                Button(playAgainButtonLabel) {
                    if currentWordIndex == wordsToGuess.count {
                        playAgainButtonLabel = "Another Word?"
                        currentWordIndex = 0
                        wordsGuessed = 0
                        wordsMissed = 0
                    }
                    wordToGuess = wordsToGuess[currentWordIndex]
                    revealedWord = "_" + String.init(repeating: " _", count: wordToGuess.count-1)
                    lettersGuessed = ""
                    guessesRemaining = maximumGuesses
                    imageName = "flower\(guessesRemaining)"
                    gameStatusMessage = "How many guesses to unccover the hidden word?"
                    playAgain = true
                    
                }
                .buttonStyle(.borderedProminent)
                .tint(.mint)
            }
            Spacer()
            
            Image(imageName)
                .resizable()
                .scaledToFit()
                .animation(.easeIn(duration: 0.75), value: imageName)
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear() {
            wordToGuess = wordsToGuess[currentWordIndex]
            guessesRemaining = maximumGuesses
            revealedWord = "_" + String.init(repeating: " _", count: wordToGuess.count-1)
        }
    }
    
    func guessALetter() {
        lettersGuessed.append(guessedLetter)
        revealedWord = ""
        for letter in wordToGuess {
            if lettersGuessed.contains(letter) {
                revealedWord = revealedWord + "\(letter) "
            } else {
                revealedWord = revealedWord + "_ "
            }
        }
        revealedWord.removeLast()
        textFieldIsFocused = false
        updateGamePlay()
    }
    func updateGamePlay() {
        if !wordToGuess.contains(guessedLetter) {
            guessesRemaining -= 1
            imageName = "wilt\(guessesRemaining)"
            playSound(soundName: "incorrect")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) { imageName = "flower\(guessesRemaining)"
            }
        }
        else {
            playSound(soundName: "correct")
        }
        if !revealedWord.contains("_") {
            playSound(soundName: "word-guessed")
            gameStatusMessage = "You've guessed it! It took you \(lettersGuessed.count) guesses to guess the word."
            wordsGuessed += 1
            currentWordIndex += 1
            playAgain = false
        } else if guessesRemaining == 0 {
            playSound(soundName: "word-not-guessed")
            gameStatusMessage = "Sorry, all out of guesses."
            wordsMissed += 1
            currentWordIndex += 1
            playAgain = false
        } else {
            gameStatusMessage = "You've made \(lettersGuessed.count) guess\(lettersGuessed.count == 1 ? "" : "es")"
        }
        guessedLetter = ""
        if currentWordIndex == wordsToGuess.count {
            gameStatusMessage = "You've tried all of the words.  Restart from the beginning?"
            playAgainButtonLabel = "Restart game?"
        }
    }
    func playSound(soundName: String) {
        guard let soundFile = NSDataAsset(name: soundName) else {
            print("Could not read file named \(soundName)")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(data: soundFile.data)
            audioPlayer.play()
        } catch {
            print("😡 Error: \(error.localizedDescription) creating audioPlayer")
        }
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
