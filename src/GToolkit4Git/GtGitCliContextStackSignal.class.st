Class {
	#name : #GtGitCliContextStackSignal,
	#superclass : #ContextStackSignal,
	#traits : 'TGtBeaconSignalStartEndType',
	#classTraits : 'TGtBeaconSignalStartEndType classTrait',
	#instVars : [
		'args',
		'output',
		'operation'
	],
	#category : #'GToolkit4Git-Libgit-CLI-GT'
}

{ #category : #'instance creation' }
GtGitCliContextStackSignal class >> args: aCollection [
	^ self new args: aCollection
]

{ #category : #'instance creation' }
GtGitCliContextStackSignal class >> args: aCollection output: aCollectionOfStrings [
	^ self new
		args: aCollection;
		output: aCollectionOfStrings;
		yourself
]

{ #category : #accessing }
GtGitCliContextStackSignal class >> eventType [
	^ GtGitCliEvent
]

{ #category : #'system startup & shutdown' }
GtGitCliContextStackSignal class >> install [
	IceGitCliPlatform current signalClass: self
]

{ #category : #accessing }
GtGitCliContextStackSignal >> args [
	^ args
]

{ #category : #accessing }
GtGitCliContextStackSignal >> args: aCollection [
	args := aCollection
]

{ #category : #accessing }
GtGitCliContextStackSignal >> asJson [
	^ NeoJSONObject new
		timestamp: self timestamp printString;
		name: self name;
		processId: self processId;
		eventType: eventType;
		operation: operation;
		args: self args
]

{ #category : #'gt extensions' }
GtGitCliContextStackSignal >> gtActionMemoryLoggerFor: anAction [
	<gtClassAction>
	^ anAction action
		title: 'Memory logger';
		priority: 30
]

{ #category : #'gt extensions' }
GtGitCliContextStackSignal >> gtGitInvocationFor: aView [
	<gtView>
	^ aView list
		title: 'Git args';
		priority: 30;
		items: [ self args ]
]

{ #category : #'gt extensions' }
GtGitCliContextStackSignal >> gtGitOperationFor: aView [
	<gtView>
	self operation ifNil: [ ^ aView empty ].
	^ aView text
		title: 'Git operation';
		priority: 20;
		text: [ self operation ]
]

{ #category : #'gt extensions' }
GtGitCliContextStackSignal >> gtGitOutputFor: aView [
	<gtView>
	^ aView list
		title: 'Git output';
		priority: 35;
		items: [ self output ifNil: [ #() ] ]
]

{ #category : #testing }
GtGitCliContextStackSignal >> hasOutput [
	^ self output notNil
]

{ #category : #accessing }
GtGitCliContextStackSignal >> initializeFromTimestamp: aDateAndTime andData: aCollection [ 
	timestamp := aDateAndTime.
	processId := aCollection third.
	aCollection fourth = 'S' 
		ifTrue: [ self markAsStartSignal ] 
		ifFalse: [ self markAsEndSignal ].
	args := aCollection fifth splitOn: Character space
]

{ #category : #accessing }
GtGitCliContextStackSignal >> operation [
	^ operation
]

{ #category : #accessing }
GtGitCliContextStackSignal >> operation: aSelector [
	operation := aSelector
]

{ #category : #accessing }
GtGitCliContextStackSignal >> output [
	^ output
]

{ #category : #accessing }
GtGitCliContextStackSignal >> output: aCollectionOfStrings [
	output := aCollectionOfStrings
]

{ #category : #printing }
GtGitCliContextStackSignal >> printOneLineContentsOn: aStream [
	args
		do: [ :arg | aStream nextPutAll: arg ]
		separatedBy: [ aStream nextPut: $  ]
]

{ #category : #accessing }
GtGitCliContextStackSignal >> signalTypeLabel [
	^ 'GtGitCliSignal'
]

{ #category : #printing }
GtGitCliContextStackSignal >> stdoutPrintString [
	^ String streamContents: [ :out |
		self timestamp printOn: out.
		out 
			nextPutAll: ' | ';
			nextPutAll: self name;
			nextPutAll: ' | ';
			nextPutAll: self processId;
			nextPutAll: ' | '.
		operation 
			ifNotNil: [ out print: operation; nextPutAll: ' | ' ].
		eventType ifNotNil: [
			out 
				nextPut: (self isStartSignalType ifTrue: [ $S ] ifFalse: [ $E ]);
				nextPutAll: ' | ' ].
		self printOneLineContentsOn: out ]
]
