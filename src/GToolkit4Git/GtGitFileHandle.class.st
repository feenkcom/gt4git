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
	| proc |
	proc := reference fileSystem store repository git.
	proc
		arguments: {'cat-file'.
				'blob'.
				entry id}.
	proc runAndWait.
	proc isSuccess ifFalse: [ self error: 'git error' ].
	^ ZnBufferedReadStream on: proc stdout asByteArray readStream
]
