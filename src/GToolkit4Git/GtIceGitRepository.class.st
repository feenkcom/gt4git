Class {
	#name : #GtIceGitRepository,
	#superclass : #IceRepository,
	#instVars : [
		'location'
	],
	#category : #'GToolkit4Git-Libgit-replace'
}

{ #category : #accessing }
GtIceGitRepository >> addFilesToIndex: aCollection [
	| builder exitValue |
	builder := GtExternalProcessBuilder new
			workingDirectory: location asString;
			command: self git;
			arg: 'add';
			args: (aCollection
					collect: [ :each | 
						self assert: each asFileReference isRelative.
						each asFileReference path pathString ]).
	exitValue := builder status.
	exitValue = 0 ifFalse: [ self error: 'git error' ]
]

{ #category : #actions }
GtIceGitRepository >> git [
	^ '/opt/local/bin/git'
]

{ #category : #actions }
GtIceGitRepository >> initBare: isBareRepository [
	| builder exitValue |
	builder := GtExternalProcessBuilder new
			workingDirectory: location asString;
			command: self git;
			arg: 'init'.
	isBareRepository ifTrue: [ builder arg: '--bare' ].
	exitValue := builder status.
	exitValue = 0 ifFalse: [ self error: 'git error' ]
]

{ #category : #accessing }
GtIceGitRepository >> location [
	^ location
]

{ #category : #actions }
GtIceGitRepository >> location: aLocation [
	location := aLocation 
]

{ #category : #'private - changes' }
GtIceGitRepository >> newIndex [
	
	^ GtIceGitIndex on: self
]

{ #category : #accessing }
GtIceGitRepository >> newNoCommit [
	^ IceNoCommit repository: self
]
