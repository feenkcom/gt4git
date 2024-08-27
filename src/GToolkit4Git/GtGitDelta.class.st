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
		oldFileRelative: aDiffDelta oldFile path;
		oldFile: aRepository location / aDiffDelta oldFile path;
		newFileRelative: aDiffDelta newFile path;
		newFile: aRepository location / aDiffDelta newFile path;
		status: aDiffDelta status
]

{ #category : #'instance creation' }
GtGitDelta class >> fromStatusLine: line in: aRepository [
	| file statusChar |
	statusChar := line trimLeft first.
	file := line copyFrom: 4 to: line size.
	^ self new
		oldFileRelative: file;
		oldFile: aRepository location resolve / file;
		newFileRelative: file copy;
		newFile: aRepository location resolve / file;
		status: (aRepository deltaTypeEnumFrom: statusChar)
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
