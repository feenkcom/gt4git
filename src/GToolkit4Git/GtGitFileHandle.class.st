Class {
	#name : #GtGitFileHandle,
	#superclass : #FileSystemHandle,
	#instVars : [
		'entry'
	],
	#category : #'GToolkit4Git-Libgit-replace'
}

{ #category : #accessing }
GtGitFileHandle >> binaryReadStream [
	^ self readStream
]

{ #category : #accessing }
GtGitFileHandle >> open [
	entry := self basicOpen
]

{ #category : #accessing }
GtGitFileHandle >> readStream [
	| id proc |
	id := (entry splitOn: $ ) third copyUpTo: Character tab.
	proc := reference fileSystem store repository git.
	proc
		arguments: {'cat-file'.
				'blob'.
				id}.
	proc runAndWait.
	proc isSuccess ifFalse: [ self error: 'git error' ].
	^ ZnBufferedReadStream on: (proc stdout asByteArray readStream)
]
