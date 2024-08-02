Class {
	#name : #GtGitDelta,
	#superclass : #Object,
	#instVars : [
		'oldFile',
		'newFile',
		'status',
		'oldFileRelative',
		'newFileRelative'
	],
	#category : #'GToolkit4Git-Model'
}

{ #category : #'instance creation' }
GtGitDelta class >> from: aDiffDelta in: aRepository [
	^ self new
		oldFileRelative: aDiffDelta oldFile path copy;
		oldFile: aRepository location resolve / aDiffDelta oldFile path copy;
		newFileRelative: aDiffDelta newFile path copy;
		newFile: aRepository location resolve / aDiffDelta newFile path copy;
		status: aDiffDelta status copy
]

{ #category : #'API - accessing' }
GtGitDelta class >> fromStatusLine: line in: aRepository [
	| file status |
	file := line copyFrom: 4 to: line size.
	status := (line copyUpTo: 3) trimBoth.
	^ self new
		oldFileRelative: file;
		oldFile: aRepository location resolve / file;
		newFileRelative: file copy;
		newFile: aRepository location resolve / file;
		status: status
]

{ #category : #accessing }
GtGitDelta >> icon [

	^ self status icon
]

{ #category : #accessing }
GtGitDelta >> newFile [
	^ newFile
]

{ #category : #accessing }
GtGitDelta >> newFile: aPath [
	newFile := aPath
]

{ #category : #accessing }
GtGitDelta >> newFileRelative [
	^ newFileRelative
]

{ #category : #accessing }
GtGitDelta >> newFileRelative: aPath [
	newFileRelative := aPath
]

{ #category : #accessing }
GtGitDelta >> oldFile [
	^ oldFile
]

{ #category : #accessing }
GtGitDelta >> oldFile: aPath [
	oldFile := aPath
]

{ #category : #accessing }
GtGitDelta >> oldFileRelative [
	^ oldFileRelative
]

{ #category : #accessing }
GtGitDelta >> oldFileRelative: aPath [
	oldFileRelative := aPath
]

{ #category : #accessing }
GtGitDelta >> printOn: aStream [
	super printOn: aStream.
	aStream
		<< '(';
		<< self newFileRelative;
		<< ')'
]

{ #category : #accessing }
GtGitDelta >> status [
	^ status
]

{ #category : #accessing }
GtGitDelta >> status: aStatus [
	status := aStatus
]
