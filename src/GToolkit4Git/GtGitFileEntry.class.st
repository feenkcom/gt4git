Class {
	#name : #GtGitFileEntry,
	#superclass : #Object,
	#instVars : [
		'mode',
		'type',
		'id',
		'size',
		'path'
	],
	#category : #'GToolkit4Git-Libgit-replace'
}

{ #category : #'instance creation' }
GtGitFileEntry class >> fromLine: aString [
	"Create an entry from a git ls-tree line produced with: '--format=%(objectmode) %(objecttype) %(objectname) %(objectsize)%x09%(path)'."

	| tabSplit path spaceSplit mode type id size |
	tabSplit := aString splitOn: Character tab.
	path := tabSplit last.
	spaceSplit := tabSplit first splitOn: Character space.
	mode := spaceSplit first.
	type := spaceSplit second.
	id := spaceSplit third.
	size := spaceSplit fourth.
	^ self new
		mode: mode;
		type: type;
		id: id;
		size: (size = '-' ifTrue: [ 0 ] ifFalse: [ size asInteger ]);
		path: path;
		yourself
]

{ #category : #accessing }
GtGitFileEntry >> id [
	^ id
]

{ #category : #accessing }
GtGitFileEntry >> id: anObject [
	id := anObject
]

{ #category : #accessing }
GtGitFileEntry >> mode [
	^ mode
]

{ #category : #accessing }
GtGitFileEntry >> mode: anObject [
	mode := anObject
]

{ #category : #accessing }
GtGitFileEntry >> path [
	^ path
]

{ #category : #accessing }
GtGitFileEntry >> path: anObject [
	path := anObject
]

{ #category : #printing }
GtGitFileEntry >> printOn: aStream [
	aStream
		nextPutAll: self className , ' ' , mode , ' ' , type , ' ' , id , ' ' , size printString
				, ' ' , path
]

{ #category : #accessing }
GtGitFileEntry >> size [
	^ size
]

{ #category : #accessing }
GtGitFileEntry >> size: anObject [
	size := anObject
]

{ #category : #accessing }
GtGitFileEntry >> type [
	^ type
]

{ #category : #accessing }
GtGitFileEntry >> type: anObject [
	type := anObject
]
