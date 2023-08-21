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
GtGitFileHandle >> entry [
	^ entry
]

{ #category : #accessing }
GtGitFileHandle >> entry: anObject [
	entry := anObject
]

{ #category : #accessing }
GtGitFileHandle >> open [
	entry := self basicOpen
]

{ #category : #accessing }
GtGitFileHandle >> readStream [
	^ reference fileSystem store repository readStreamOn: self
]
