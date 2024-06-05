"
I am GtGitRepositoryHistoryRecord.
I capture the state of a Iceberg git repository so that it could be recreated in the future.

In particular, I hold the following information:
- name
- originUrl
- headCommitId
- packages

"
Class {
	#name : #GtGitRepositoryHistoryRecord,
	#superclass : #Object,
	#instVars : [
		'name',
		'originUrl',
		'headCommitId',
		'packages'
	],
	#category : #'GToolkit4Git-Tools'
}

{ #category : #accessing }
GtGitRepositoryHistoryRecord class >> capture: aRepository [
	| record |
	record := self new.
	record name: aRepository name.
	aRepository isMissing
		ifFalse: [ 
			record originUrl: aRepository originUrl.
			record headCommitId: aRepository head commit id ].
	aRepository workingCopy packages do: [ :each |
		record packages add: each name ].
	^ record
]

{ #category : #example }
GtGitRepositoryHistoryRecord class >> exampleGt4Git [
	<gtExample>
	
	| repository record |
	repository := IceRepository repositoryNamed: 'gt4git'.
	record := self capture: repository.
	self assert: record name = 'gt4git'.
	^ record
]

{ #category : #'gt extensions' }
GtGitRepositoryHistoryRecord >> gtViewDetailsIn: composite [
	<gtView>
	
	^ composite columnedList
		title: 'Details';
		priority: 20;
		items: [ {
			{ 'name' . self name }.
			{ 'origin' . self originUrl ifNil: [ '' ] . self originUrl }.
			{ 'commit' . self headCommitId ifNil: [ '' ] . self headCommitId }.
			{ 'packages'
				. (', ' join: self packages)
				. self packages } 
		} ];
		column: 'key' text: #first weight: 0.5;
		column: 'value' text: #second;
		send: #last
]

{ #category : #accessing }
GtGitRepositoryHistoryRecord >> headCommitId [
	^ headCommitId
]

{ #category : #accessing }
GtGitRepositoryHistoryRecord >> headCommitId: aHash [
	headCommitId := aHash
]

{ #category : #initialization }
GtGitRepositoryHistoryRecord >> initialize [
	super initialize.
	packages := OrderedCollection new
]

{ #category : #accessing }
GtGitRepositoryHistoryRecord >> name [
	^ name
]

{ #category : #accessing }
GtGitRepositoryHistoryRecord >> name: aString [
	name := aString
]

{ #category : #accessing }
GtGitRepositoryHistoryRecord >> originUrl [
	^ originUrl
]

{ #category : #accessing }
GtGitRepositoryHistoryRecord >> originUrl: aString [
	originUrl := aString
]

{ #category : #accessing }
GtGitRepositoryHistoryRecord >> packages [
	^ packages
]
