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

{ #category : #accessing }
GitCliCommitFileReader >> eatNewline [
	self getNextByte
]

{ #category : #accessing }
GitCliCommitFileReader >> getNext: anInteger [
	^ ByteArray
		streamContents: [ :str | anInteger timesRepeat: [ str nextPut: self getNextByte ] ]
]

{ #category : #accessing }
GitCliCommitFileReader >> getNextByte [
	[ buffer isEmpty ] whileTrue: [ buffer addAll: stdout pollBytes ].
	^ buffer removeFirst
]

{ #category : #accessing }
GitCliCommitFileReader >> getNextLine [
	^ String
		streamContents: [ :str | 
			| ch lfCode |
			lfCode := Character lf asciiValue.
			[
			ch := self getNextByte.
			ch = lfCode ] whileFalse: [ str nextPut: (Character value: ch) ] ]
]

{ #category : #accessing }
GitCliCommitFileReader >> initialize [
	super initialize.
	lock := Mutex new.
	pollRate := 1 second.
	timeout := 15 seconds.
	lastAccess := DateAndTime now
]

{ #category : #accessing }
GitCliCommitFileReader >> readStreamFor: aString [
	lock
		critical: [ externalProcess isNil
				ifTrue: [ self startExternalProcess.
					self startWatchDog ].
			lastAccess := DateAndTime now.
			^ self requestReadStreamFor: aString ]
]

{ #category : #accessing }
GitCliCommitFileReader >> requestReadStreamFor: aString [
	| line out bytes |
	stdin
		nextPutAll: aString;
		lf.
	line := self getNextLine.
	bytes := (line splitOn: Character space) third asInteger.
	out := self getNext: bytes.
	self eatNewline.
	^ ZnBufferedReadStream on: out readStream
]

{ #category : #accessing }
GitCliCommitFileReader >> startExternalProcess [
	externalProcess := (GtExternalProcessBuilder new: 'git')
			workingDirectory: workingDirectory;
			args: {'cat-file'.
					'--batch'};
			pipeStdin;
			pipeStdout;
			pipeStderr;
			spawn.
	stdout := externalProcess asynchronousStdout.
	stderr := externalProcess asynchronousStderr.
	stdin := externalProcess stdin.
	buffer := OrderedCollection new
]

{ #category : #accessing }
GitCliCommitFileReader >> startWatchDog [
	watchDog := [ [ pollRate asDelay wait.
		lock
			critical: [ DateAndTime now - lastAccess > timeout ifTrue: [ self terminate ] ] ]
			repeat ] fork
]

{ #category : #accessing }
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

{ #category : #accessing }
GitCliCommitFileReader >> workingDirectory: aFileRef [
	workingDirectory := aFileRef 
]
