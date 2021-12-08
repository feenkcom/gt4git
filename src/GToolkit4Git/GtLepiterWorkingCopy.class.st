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
		changes add: (GtLepiterDatabaseChange new
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

{ #category : #accessing }
GtLepiterWorkingCopy >> repository [

	^ repository
]

{ #category : #accessing }
GtLepiterWorkingCopy >> repository: anObject [

	repository := anObject
]

{ #category : #accessing }
GtLepiterWorkingCopy >> updateDatabases [
	| allDatabases |
	allDatabases := LeDatabasesRegistry default defaultLogicalDatabase databases.
	self databases: (allDatabases select: [ :aDatabase | 
		self repository repositoryDirectory 
			contains: aDatabase monitor localRoot ])
]
