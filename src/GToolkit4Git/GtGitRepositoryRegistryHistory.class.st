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

{ #category : #'gt - extensions' }
GtGitRepositoryRegistryHistory class >> gtActionInspectInstanceFor: anAction [
	<gtAction>
	<gtClassAction>
	
	self hasInstace ifFalse: [ ^ anAction noAction ].
	
	^ anAction button
		icon: BrGlamorousVectorIcons inspect;
		label: 'Instance';
		tooltip: 'Inspect instance';
		priority: 10;
		action: [ :aButton | aButton phlow spawnObject: self instance ]
]

{ #category : #'gt - extensions' }
GtGitRepositoryRegistryHistory class >> gtViewDefaultRecordsIn: aView [
	<gtView>
	<gtClassView>
	
	self hasInstace ifFalse: [ ^ aView empty ].
	
	^ aView forward
		title: 'Records';
		priority: 20;
		object: [ self instance ];
		view:#gtViewRecordsFor: 
]

{ #category : #testing }
GtGitRepositoryRegistryHistory class >> hasInstace [ 
	^ instance notNil
]

{ #category : #accessing }
GtGitRepositoryRegistryHistory class >> instance [
	^ instance ifNil: [ instance := self new ]
]

{ #category : #operations }
GtGitRepositoryRegistryHistory >> capture [
	<gtExample>
	
	self records removeAll.
	IceRepository registry do: [ :each |
		self records 
			add: (GtGitRepositoryHistoryRecord capture: each) ]
]

{ #category : #'gt extensions' }
GtGitRepositoryRegistryHistory >> gtViewRecordsFor: aView [
	<gtView>
	
	^ aView columnedList
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
GtGitRepositoryRegistryHistory >> repositoriesIncludingPackage: packageName [
	^ self records
		select: [ :each | each includesPackageNamed: packageName ] 
]

{ #category : #accessing }
GtGitRepositoryRegistryHistory >> repositoryIncludingPackage: packageName [
	^ self records
		detect: [ :each | each includesPackageNamed: packageName ]
		ifNone: [ nil ] 
]

{ #category : #accessing }
GtGitRepositoryRegistryHistory >> repositoryNamed: aRepositoryName [
	^ self records 
		detect: [ :each | each name = aRepositoryName ] 
		ifNone: [ nil ]
]
