Class {
	#name : #GtGitCliSignal,
	#superclass : #ContextStackSignal,
	#traits : 'TGtBeaconSignalStartEndType',
	#classTraits : 'TGtBeaconSignalStartEndType classTrait',
	#instVars : [
		'args',
		'output',
		'operation'
	],
	#classVars : [
		'memoryLogger'
	],
	#category : #'GToolkit4Git-Libgit-CLI'
}

{ #category : #'instance creation' }
GtGitCliSignal class >> args: aCollection [
	^self new args: aCollection
]

{ #category : #'instance creation' }
GtGitCliSignal class >> args: aCollection output: aCollectionOfStrings [
	^ self new
		args: aCollection;
		output: aCollectionOfStrings;
		yourself
]

{ #category : #accessing }
GtGitCliSignal class >> eventType [
	^GtGitCliEvent
]

{ #category : #logging }
GtGitCliSignal class >> groupedEvents [
	^ GtGitCliEventsGrouper new 
		processEventSignalsFor: self memoryLogger recordings;
		yourself
]

{ #category : #'gt extensions' }
GtGitCliSignal class >> gtActionGroupedEventsFor: anAction [
	<gtClassAction>
	^ anAction button
		label: 'Events';
		tooltip: 'Inspect grouped events';
		priority: 35;
		action: [ :element | element phlow spawnObject: self groupedEvents ]
]

{ #category : #'gt extensions' }
GtGitCliSignal class >> gtActionMemoryLoggerFor: anAction [
	<gtClassAction>
	^ anAction button
		label: 'Logger';
		tooltip: 'Inspect memory logger';
		priority: 30;
		action: [ :element | element phlow spawnObject: self memoryLogger ]
]

{ #category : #initialization }
GtGitCliSignal class >> initialize [
	SessionManager default registerUserClassNamed: self name.
	self startUp
]

{ #category : #logging }
GtGitCliSignal class >> logToStdout [
	self stopLoggingToStdout.
	^ Beacon instance announcer
		when: GtGitCliSignal 
		do: [ :signal | Stdio stdout nextPutAll: signal stdoutPrintString; lf; flush ] 
		for: #git_cli_log_to_stdout
]

{ #category : #logging }
GtGitCliSignal class >> memoryLogger [
	^ memoryLogger
		ifNil: [ 
			memoryLogger := CircularMemoryLogger named: self name.
			memoryLogger entryCount: 64.
			memoryLogger startFor: self.
			memoryLogger ]
]

{ #category : #logging }
GtGitCliSignal class >> startMemoryLogger [
	self memoryLogger reset; start
]

{ #category : #'system startup & shutdown' }
GtGitCliSignal class >> startUp [
	self startMemoryLogger
]

{ #category : #logging }
GtGitCliSignal class >> stopLoggingToStdout [
	^ Beacon instance unsubscribe: #git_cli_log_to_stdout
]

{ #category : #logging }
GtGitCliSignal class >> stopMemoryLogger [
	memoryLogger ifNil: [ ^ self ].
	self memoryLogger stop
]

{ #category : #accessing }
GtGitCliSignal >> args [
	^ args
]

{ #category : #accessing }
GtGitCliSignal >> args: aCollection [
	args := aCollection
]

{ #category : #accessing }
GtGitCliSignal >> asJson [
	^ NeoJSONObject new
		timestamp: self timestamp printString;
		name: self name;
		processId: self processId;
		eventType: eventType;
		operation: operation;
		args: self args
]

{ #category : #'gt extensions' }
GtGitCliSignal >> gtActionMemoryLoggerFor: anAction [
	<gtClassAction>
	^ anAction action
		title: 'Memory logger';
		priority: 30
]

{ #category : #'gt extensions' }
GtGitCliSignal >> gtGitInvocationFor: aView [
	<gtView>
	^ aView list
		title: 'Git args';
		priority: 30;
		items: [ self args ]
]

{ #category : #'gt extensions' }
GtGitCliSignal >> gtGitOperationFor: aView [
	<gtView>
	self operation ifNil: [ ^ aView empty ].
	^ aView text
		title: 'Git operation';
		priority: 20;
		text: [ self operation ]
]

{ #category : #'gt extensions' }
GtGitCliSignal >> gtGitOutputFor: aView [
	<gtView>
	^ aView list
		title: 'Git output';
		priority: 35;
		items: [ self output ifNil: [ #() ] ]
]

{ #category : #testing }
GtGitCliSignal >> hasOutput [
	^ self output notNil
]

{ #category : #accessing }
GtGitCliSignal >> initializeFromTimestamp: aDateAndTime andData: aCollection [ 
	timestamp := aDateAndTime.
	processId := aCollection third.
	aCollection fourth = 'S' 
		ifTrue: [ self markAsStartSignal ] 
		ifFalse: [ self markAsEndSignal ].
	args := aCollection fifth splitOn: Character space
]

{ #category : #accessing }
GtGitCliSignal >> operation [
	^ operation
]

{ #category : #accessing }
GtGitCliSignal >> operation: aSelector [
	operation := aSelector
]

{ #category : #accessing }
GtGitCliSignal >> output [
	^ output
]

{ #category : #accessing }
GtGitCliSignal >> output: aCollectionOfStrings [
	output := aCollectionOfStrings
]

{ #category : #printing }
GtGitCliSignal >> printOneLineContentsOn: aStream [
	args
		do: [ :arg | aStream nextPutAll: arg ]
		separatedBy: [ aStream nextPut: $  ]
]

{ #category : #accessing }
GtGitCliSignal >> signalTypeLabel [
	^ 'GtGitCliSignal'
]

{ #category : #printing }
GtGitCliSignal >> stdoutPrintString [
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
