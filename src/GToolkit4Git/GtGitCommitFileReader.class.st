Class {
	#name : #GtGitCommitFileReader,
	#superclass : #Object,
	#instVars : [
		'workingDirectory',
		'externalProcess',
		'stdout',
		'stdin',
		'stderr',
		'buffer',
		'lock'
	],
	#category : #'GToolkit4Git-Libgit-replace'
}

{ #category : #accessing }
GtGitCommitFileReader >> eatNewline [
	self getNextByte
]

{ #category : #accessing }
GtGitCommitFileReader >> getNext: anInteger [
	^ ByteArray
		streamContents: [ :str | anInteger timesRepeat: [ str nextPut: self getNextByte ] ]
]

{ #category : #accessing }
GtGitCommitFileReader >> getNextByte [
	[ buffer isEmpty ] whileTrue: [ buffer addAll: stdout pollBytes ].
	^ buffer removeFirst
]

{ #category : #accessing }
GtGitCommitFileReader >> getNextLine [
	^ String
		streamContents: [ :str | 
			| ch lfCode |
			lfCode := Character lf asciiValue.
			[
			ch := self getNextByte.
			ch = lfCode ] whileFalse: [ str nextPut: (Character value: ch) ] ]
]

{ #category : #accessing }
GtGitCommitFileReader >> readStreamFor: aString [
	| out line bytes |
	lock
		critical: [ stdin
				nextPutAll: aString;
				lf.
			line := self getNextLine.
			bytes := (line splitOn: Character space) third asInteger.
			out := self getNext: bytes.
			self eatNewline.
			^ ZnBufferedReadStream on: out readStream ]
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
	lock := Mutex new.
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
