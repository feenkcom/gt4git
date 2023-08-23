Class {
	#name : #GtGitCommitFileReader,
	#superclass : #Object,
	#instVars : [
		'workingDirectory',
		'externalProcess',
		'stdout',
		'stdin',
		'stderr',
		'buffer'
	],
	#classVars : [
		'Registry'
	],
	#category : #'GToolkit4Git-Libgit-replace'
}

{ #category : #accessing }
GtGitCommitFileReader class >> registry [
	^ Registry ifNil: [ Registry := WeakRegistry new ]
]

{ #category : #accessing }
GtGitCommitFileReader >> eatNewline [
	self getNextChar
]

{ #category : #accessing }
GtGitCommitFileReader >> getNext: anInteger [
	^ ByteArray
		streamContents: [ :str | anInteger timesRepeat: [ str nextPut: self getNextChar asInteger ] ]
]

{ #category : #accessing }
GtGitCommitFileReader >> getNextChar [
	[ buffer isEmpty ] whileTrue: [ buffer addAll: stdout pollString ].
	^ buffer removeFirst
]

{ #category : #accessing }
GtGitCommitFileReader >> getNextLine [
	^ String
		streamContents: [ :str | 
			| ch |
			[ ch := self getNextChar.
			ch = Character lf ] whileFalse: [ str nextPut: ch ] ]
]

{ #category : #accessing }
GtGitCommitFileReader >> readStreamFor: aString [
	| out line bytes |
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
GtGitCommitFileReader >> start [
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
	buffer := OrderedCollection new.
	self class registry
		add: self
		executor: (ObjectFinalizer receiver: self selector: #terminate)
]

{ #category : #accessing }
GtGitCommitFileReader >> terminate [
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
			stdin := nil ]
]

{ #category : #accessing }
GtGitCommitFileReader >> workingDirectory: aFileRef [
	workingDirectory := aFileRef 
]
