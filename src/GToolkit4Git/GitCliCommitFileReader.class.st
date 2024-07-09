"
This class it used to access the files within a git commit. For performance sake, we are using the --batch mode of git cat-file.
In order to prevent the file system from keeping a long-running git process around (and survive image saves) we are using a watchdog
timer to close the connection if unused for a period of time.
"
Class {
	#name : #GitCliCommitFileReader,
	#superclass : #Object,
	#instVars : [
		'workingDirectory',
		'externalProcess',
		'stdout',
		'stdin',
		'stderr',
		'buffer',
		'lock',
		'pollRate',
		'timeout',
		'lastAccess',
		'watchDog'
	],
	#category : #'GToolkit4Git-Libgit-CLI'
}

{ #category : #private }
GitCliCommitFileReader >> eatNewline [
	self getNextByte
]

{ #category : #private }
GitCliCommitFileReader >> ensureExternalProcess [
	externalProcess isNil
		ifTrue: [ self startExternalProcess.
			self startWatchDog ]
]

{ #category : #private }
GitCliCommitFileReader >> getNext: anInteger [
	^ ByteArray 
		new: anInteger
		streamContents: [ :str | anInteger timesRepeat: [ str nextPut: self getNextByte ] ]
]

{ #category : #private }
GitCliCommitFileReader >> getNextByte [
	[ buffer isEmpty ] whileTrue: [ buffer addAll: stdout pollBytes ].
	^ buffer removeFirst
]

{ #category : #private }
GitCliCommitFileReader >> getNextLine [
	| bytes |
	bytes := ByteArray
			streamContents: [ :str | 
				| byte linefeed |
				linefeed := Character linefeed asciiValue.
				[ byte := self getNextByte.
				byte = linefeed ] whileFalse: [ str nextPut: byte ] ].
	^ bytes decodeWith: #null
]

{ #category : #'initialize - release' }
GitCliCommitFileReader >> initialize [
	super initialize.
	lock := Mutex new.
	pollRate := 1 second.
	timeout := 15 seconds.
	lastAccess := DateAndTime now
]

{ #category : #logging }
GitCliCommitFileReader >> logEnded: operation args: args output: output [
	self loggingEnabled
		ifTrue: [ (IceGitCliPlatform current signalClass args: args output: output)
				operation: operation;
				markAsEndSignal;
				emit ]
]

{ #category : #logging }
GitCliCommitFileReader >> logStarted: operation args: args [
	self loggingEnabled
		ifTrue: [ (IceGitCliPlatform current signalClass args: args)
				operation: operation;
				markAsStartSignal;
				emit ]
]

{ #category : #logging }
GitCliCommitFileReader >> loggingEnabled [
	^ IceGitCliPlatform current signalClass notNil
]

{ #category : #accessing }
GitCliCommitFileReader >> readStreamFor: aString [
	| args stream |
	args := { 'cat-file' . '--batch' . aString }.
	self logStarted: #readStreamFor: args: args.
	lock
		critical: [ self ensureExternalProcess.
			lastAccess := DateAndTime now.
			stream := self requestReadStreamFor: aString ].
	self logEnded: #readStreamFor: args: args output: { stream size asString , ' bytes' }.
	^ stream
]

{ #category : #private }
GitCliCommitFileReader >> requestReadStreamFor: aString [
	| line byteCount bytes |
	stdin nextPutAll: aString; lf.
	line := self getNextLine.
	byteCount := (line splitOn: Character space) third asInteger.
	bytes := self getNext: byteCount.
	self eatNewline.
	^ bytes readStream
]

{ #category : #private }
GitCliCommitFileReader >> startExternalProcess [
	externalProcess := (GtExternalProcessBuilder new: IceGitCliPlatform current gitExecutable)
			workingDirectory: workingDirectory;
			args: { 'cat-file' . '--batch' };
			pipeStdin;
			pipeStdout;
			pipeStderr;
			spawn.
	stdout := externalProcess asynchronousStdout.
	stderr := externalProcess asynchronousStderr.
	stdin := externalProcess stdin.
	buffer := OrderedCollection new
]

{ #category : #private }
GitCliCommitFileReader >> startWatchDog [
	watchDog := [ [ pollRate asDelay wait.
		lock
			critical: [ DateAndTime now - lastAccess > timeout ifTrue: [ self terminate ] ] ]
			repeat ] forkNamed: 'Git CLI commit file reader watchdog'
]

{ #category : #'initialize - release' }
GitCliCommitFileReader >> terminate [
	externalProcess
		ifNotNil: [ externalProcess terminate.
			externalProcess := nil ].
	stderr
		ifNotNil: [ stderr release.
			stderr := nil ].
	stdout
		ifNotNil: [ stdout release.
			stdout := nil ].
	stdin
		ifNotNil: [ stdin release.
			stdin := nil ].
	watchDog ifNotNil: [ watchDog terminate ]
]

{ #category : #'initialize - release' }
GitCliCommitFileReader >> workingDirectory: aFileRef [
	workingDirectory := aFileRef 
]
