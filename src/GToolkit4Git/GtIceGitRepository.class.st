Class {
	#name : #GtIceGitRepository,
	#superclass : #IceRepository,
	#instVars : [
		'location'
	],
	#category : #'GToolkit4Git-Libgit-replace'
}

{ #category : #actions }
GtIceGitRepository >> initBare: isBareRepository [
	| builder exitValue |
	builder := GtExternalProcessBuilder new
			workingDirectory: location asString;
			command: '/opt/local/bin/git';
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
