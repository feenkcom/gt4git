Class {
	#name : #GitCliFileEntry,
	#superclass : #Object,
	#instVars : [
		'mode',
		'type',
		'id',
		'size',
		'path'
	],
	#category : #'GToolkit4Git-Libgit-CLI'
}

{ #category : #'instance creation' }
GitCliFileEntry class >> fromLine: aString [
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
GitCliFileEntry >> filename [
	^path
]

{ #category : #accessing }
GitCliFileEntry >> id [
	^ id
]

{ #category : #accessing }
GitCliFileEntry >> id: anObject [
	id := anObject
]

{ #category : #accessing }
GitCliFileEntry >> mode [
	^ mode
]

{ #category : #accessing }
GitCliFileEntry >> mode: anObject [
	mode := anObject
]

{ #category : #accessing }
GitCliFileEntry >> path [
	^ path
]

{ #category : #accessing }
GitCliFileEntry >> path: anObject [
	path := anObject
]

{ #category : #printing }
GitCliFileEntry >> printOn: aStream [
	aStream
		nextPutAll: self className , ' ' , mode , ' ' , type , ' ' , id , ' ' , size printString
				, ' ' , path
]

{ #category : #accessing }
GitCliFileEntry >> size [
	^ size
]

{ #category : #accessing }
GitCliFileEntry >> size: anObject [
	size := anObject
]

{ #category : #accessing }
GitCliFileEntry >> type [
	^ type
]

{ #category : #accessing }
GitCliFileEntry >> type: anObject [
	type := anObject
]
