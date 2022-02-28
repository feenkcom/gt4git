Class {
	#name : #GtLepiterWorkingCopy,
	#superclass : #Object,
	#instVars : [
		'databases',
		'repository',
		'lepiterChangesStragegy'
	],
	#category : #'GToolkit4Git-Lepiter'
}

{ #category : #accessing }
GtLepiterWorkingCopy >> addDB: aDatabase [

	databases add: aDatabase.
	aDatabase announcer weak
		when: LeAnnouncement
		send: #onDatabaseChanged:
		to: self.
	aDatabase monitor announcer weak
		when: LeLocalStoreMonitorSavedChanges
		send: #onDatabaseSaved:
		to: self
]

{ #category : #testing }
GtLepiterWorkingCopy >> canRevertChanges [
	^ true
]

{ #category : #'API - changes' }
GtLepiterWorkingCopy >> changesTo: aCommitish [

	| lepiterChanges codeChanges |
	lepiterChanges := self lepiterChangesTo: aCommitish.
	codeChanges := self codeChangesTo: aCommitish.
	^ lepiterChanges asArray , codeChanges asArray
	  , { (IceGitChange on: 'README.md') }
]

{ #category : #accessing }
GtLepiterWorkingCopy >> changesToHeadUsingIndex [
	"Determine the changes between the current head commit of the repository and
	the working directory, by relying on the index."
	| changesBuilder |
	changesBuilder := GtGitLepiterChangesFromDeltasBuilder new
		databases: self databases;
		icebergRepository: self repository.
	
	^ changesBuilder changesFromDeltas: self repository getDeltasForFullDiff 
]

{ #category : #'API - changes' }
GtLepiterWorkingCopy >> codeChangesTo: aCommitish [
	^ self icebergWorkingCopy changesTo: aCommitish
]

{ #category : #accessing }
GtLepiterWorkingCopy >> databases [

	^ databases
]

{ #category : #accessing }
GtLepiterWorkingCopy >> databases: anObject [
	databases := anObject asSet.
	databases do: [ :aDatabase | 
		aDatabase announcer weak
			when: LeAnnouncement
			send: #onDatabaseChanged:
			to: self.
		aDatabase monitor announcer weak
			when: LeLocalStoreMonitorSavedChanges
			send: #onDatabaseSaved:
			to: self ]
]

{ #category : #'API - changes' }
GtLepiterWorkingCopy >> diffTo: aCommitish [

	^ IceDiff
		from: self
		to: aCommitish commit
]

{ #category : #'API - changes' }
GtLepiterWorkingCopy >> diffToReferenceCommit [

	^ self diffTo: self referenceCommit
]

{ #category : #'API - changes' }
GtLepiterWorkingCopy >> discardChanges: aTree [
	^ self icebergWorkingCopy discardChanges: aTree
]

{ #category : #accessing }
GtLepiterWorkingCopy >> fileSystem [
	^ self icebergWorkingCopy fileSystem
]

{ #category : #accessing }
GtLepiterWorkingCopy >> hasDatabases [
	^ databases size > 0
]

{ #category : #accessing }
GtLepiterWorkingCopy >> icebergWorkingCopy [
	^ self repository workingCopy
]

{ #category : #testing }
GtLepiterWorkingCopy >> includesKnowledgeWithId: anUuid [
	^ self databases anySatisfy: [ :aDatabase |
		aDatabase uuid = anUuid ] 
]

{ #category : #testing }
GtLepiterWorkingCopy >> includesPackageNamed: aString [ 
	^ self icebergWorkingCopy includesPackageNamed: aString 
]

{ #category : #initialization }
GtLepiterWorkingCopy >> initialize [ 
	super initialize.
	self lepiterChangesStragegy: GtLepiterWorkingCopyChangesUseIndexStrategy new.
]

{ #category : #accessing }
GtLepiterWorkingCopy >> lepiterChangesStragegy [
	^ lepiterChangesStragegy
]

{ #category : #accessing }
GtLepiterWorkingCopy >> lepiterChangesStragegy: aStragegy [
	lepiterChangesStragegy := aStragegy.
	aStragegy workingCopy: self.
]

{ #category : #'API - changes' }
GtLepiterWorkingCopy >> lepiterChangesTo: aCommitish [
	^ self lepiterChangesStragegy changesTo: aCommitish
]

{ #category : #accessing }
GtLepiterWorkingCopy >> onDatabaseChanged: anAnnouncement [
	(anAnnouncement isKindOf: LeDatabaseUnloadAnnouncement) ifTrue: [ 
		databases remove: anAnnouncement database ifAbsent: [] ].

	Iceberg announcer announce:
		(IceRepositoryModified for: self repository)
]

{ #category : #accessing }
GtLepiterWorkingCopy >> onDatabaseSaved: anAnnouncement [

	(databases contains: [ :aDatabase | 
		 aDatabase = anAnnouncement monitor database ]) ifFalse: [ ^ self ].

	Iceberg announcer announce:
		(IceRepositoryModified for: self repository)
]

{ #category : #accessing }
GtLepiterWorkingCopy >> project [
	^ self icebergWorkingCopy project
]

{ #category : #accessing }
GtLepiterWorkingCopy >> properties [
	^ self icebergWorkingCopy properties
]

{ #category : #accessing }
GtLepiterWorkingCopy >> referenceCommit [
	^ self icebergWorkingCopy referenceCommit
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
GtLepiterWorkingCopy >> resolveDelta: aDelta [
	^ (self fileSystem resolve: aDelta newFile) asFileReference
]

{ #category : #accessing }
GtLepiterWorkingCopy >> snapshotForKnowledgeWithId: anUuid [
	| database |
	database := self databases detect: [ :aDatabase |
		aDatabase uuid = anUuid ].
	^ GtLepiterDatabaseSnapshot fromDatabase: database.
]

{ #category : #'private - monticello' }
GtLepiterWorkingCopy >> snapshotForPackage: aPackage [ 
	^ self icebergWorkingCopy snapshotForPackage: aPackage 
]

{ #category : #accessing }
GtLepiterWorkingCopy >> updateDatabases [
	| allDatabases |
	allDatabases := LeDatabasesRegistry default 
		defaultLogicalDatabase databases.
	self repository repositoryDirectory ifNotNil: [ 
		self databases: (allDatabases select: [ :aDatabase | 
			 self repository repositoryDirectory 
			 	contains: aDatabase monitor localRoot ]) ]
]

{ #category : #initialization }
GtLepiterWorkingCopy >> useCheckAllStragegy [
	self lepiterChangesStragegy: GtLepiterWorkingCopyChangesCheckAllStrategy new
]
