"
I am GtGitRepositoryRegistryHistory.
I hold a collection of GtGitRepositoryHistoryRecord objects capturing the state of Iceberg git repositories so that they could be recreated in the future.

I have a default instance.

"
Class {
	#name : #GtGitRepositoryRegistryHistory,
	#superclass : #Object,
	#instVars : [
		'records'
	],
	#classInstVars : [
		'instance'
	],
	#category : #'GToolkit4Git-Tools'
}

{ #category : #accessing }
GtGitRepositoryRegistryHistory class >> instance [
	^ instance ifNil: [ instance := self new ]
]

{ #category : #operations }
GtGitRepositoryRegistryHistory >> capture [
	self records removeAll.
	IceRepository registry do: [ :each |
		self records 
			add: (GtGitRepositoryHistoryRecord capture: each) ]
]

{ #category : #'gt extensions' }
GtGitRepositoryRegistryHistory >> gtViewRecordsIn: composite [
	<gtView>
	
	^ composite columnedList
		title: 'Records';
		priority: 20;
		items: [ self records sorted: #name ascending];
		column: 'Name' text: #name;
		column: 'Origin' text: [ :record | record originUrl ifNil: [ '' ] ];
		column: 'Commit' text: [ :record | record headCommitId ifNil: [ '' ] ]
]

{ #category : #'initialization ' }
GtGitRepositoryRegistryHistory >> initialize [
	super initialize.
	records := OrderedCollection new
]

{ #category : #accessing }
GtGitRepositoryRegistryHistory >> records [
	^ records
]

{ #category : #accessing }
GtGitRepositoryRegistryHistory >> repositoryNamed: aRepositoryName [
	^ self records 
		detect: [ :each | each name = aRepositoryName ] 
		ifNone: [ nil ]
]
