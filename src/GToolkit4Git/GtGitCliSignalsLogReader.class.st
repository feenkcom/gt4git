Class {
	#name : #GtGitCliSignalsLogReader,
	#superclass : #Object,
	#instVars : [
		'signalTypeIndicator'
	],
	#category : #'GToolkit4Git-Libgit-replace'
}

{ #category : #api }
GtGitCliSignalsLogReader class >> readFrom: aStream [
	^ self new
		readFrom: aStream
]

{ #category : #api }
GtGitCliSignalsLogReader class >> readFromFile: aFileReference [
	^ aFileReference readStreamDo: [ :aStream | 
		self new
			readFrom: aStream ]
]

{ #category : #api }
GtGitCliSignalsLogReader >> createDefaultEventsGrouper [
	^ GtGitCliEventsGrouper new
]

{ #category : #initialization }
GtGitCliSignalsLogReader >> initialize [
	super initialize.
	
	signalTypeIndicator := 'GtGitCliSignal'
]

{ #category : #api }
GtGitCliSignalsLogReader >> processSignals: aCollectionOfSignals [
	| eventsGrouper |
	eventsGrouper := self createDefaultEventsGrouper  .
	eventsGrouper processEventSignalsFor: aCollectionOfSignals.
	^ eventsGrouper
]

{ #category : #api }
GtGitCliSignalsLogReader >> readFrom: aStream [
	| newSignals typeIndicator |
	newSignals := OrderedCollection new.
	typeIndicator := '| ', self signalTypeIndicator ,' |'.
	
	aStream contents linesDo: [ :aLine |
		(aLine includesSubstring: typeIndicator) ifTrue: [
			| newSignal |
			newSignal := self readSignalFromLine: aLine.
			newSignals add: newSignal ] ].
	
	^ self processSignals: newSignals
]

{ #category : #accessing }
GtGitCliSignalsLogReader >> readSignalFromLine: aLine [
	| timestampString signalClassName parts signalClass signal |
	
	parts := aLine splitOn: ' | '.
	
	timestampString := parts first trimBoth.
	signalClassName := parts second trimBoth.
	
	signalClass := signalClassName asClass.
	signal := signalClass new.
	signal 
		initializeFromTimestamp: timestampString asDateAndTime 
		andData: parts.
	^ signal
]

{ #category : #accessing }
GtGitCliSignalsLogReader >> signalTypeIndicator [
	^ signalTypeIndicator
]
