Class {
	#name : #GtLepiterWorkingCopy,
	#superclass : #Object,
	#instVars : [
		'databases',
		'repository'
	],
	#category : #'GToolkit4Git-Lepiter'
}

{ #category : #accessing }
GtLepiterWorkingCopy >> changesTo: aCommitish [
	| changes |
	changes := Set new.
	self databases do: [ :aDatabase |
		changes add: (GtLepiterLocalDatabaseChange new
			database: aDatabase) ].
	^ changes
]

{ #category : #accessing }
GtLepiterWorkingCopy >> databases [

	^ databases
]

{ #category : #accessing }
GtLepiterWorkingCopy >> databases: anObject [

	databases := anObject
]

{ #category : #testing }
GtLepiterWorkingCopy >> includesKnowledgeWithId: anUuid [
	^ self databases anySatisfy: [ :aDatabase |
		aDatabase uuid = anUuid ] 
]

{ #category : #accessing }
GtLepiterWorkingCopy >> repository [

	^ repository
]

{ #category : #accessing }
GtLepiterWorkingCopy >> repository: anObject [

	repository := anObject
]

{ #category : #accessing }
GtLepiterWorkingCopy >> snapshotForKnowledgeWithId: anUuid [
	| database |
	database := self databases detect: [ :aDatabase |
		aDatabase uuid = anUuid ].
	^ GtLepiterDatabaseShapshot fromDatabase: database.
]

{ #category : #accessing }
GtLepiterWorkingCopy >> updateDatabases [
	| allDatabases |
	allDatabases := LeDatabasesRegistry default defaultLogicalDatabase databases.
	self databases: (allDatabases select: [ :aDatabase | 
		self repository repositoryDirectory 
			contains: aDatabase monitor localRoot ])
]
