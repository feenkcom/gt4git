Class {
	#name : #GtLepiterWorkingCopy,
	#superclass : #Object,
	#instVars : [
		'databases',
		'icebergRepository',
		'lepiterChangesStragegy'
	],
	#category : #'GToolkit4Git-Lepiter'
}

{ #category : #actions }
GtLepiterWorkingCopy >> addDatabase: aDatabase [

	databases add: aDatabase.
	self subscribeDatabase: aDatabase.
]

{ #category : #actions }
GtLepiterWorkingCopy >> addNewDatabaseInDirectory: aDirectory [
	| newDatabase aFileLocator |
	
	aFileLocator := aDirectory gtWithClosestFileLocatorParent.
	newDatabase := LeLocalStoreLoad current 
		loadAndMonitorFrom: aFileLocator.

	LeDatabasesRegistry defaultLogicalDatabase 
		addDB: newDatabase;
		saveProperties.

	self addDatabase: newDatabase.
	
]

{ #category : #testing }
GtLepiterWorkingCopy >> canRevertChanges [
	^ true
]

{ #category : #changes }
GtLepiterWorkingCopy >> changesFromCommit: anIceCommit [
	"Delegate for now to the iceberg working copy.
	This does not take into account any Lepiter changes for now"
	^ self icebergWorkingCopy changesFromCommit: anIceCommit
]

{ #category : #'API - changes' }
GtLepiterWorkingCopy >> changesTo: aCommitish [

	| lepiterChanges codeChanges |
	lepiterChanges := self lepiterChangesTo: aCommitish.
	codeChanges := self codeChangesTo: aCommitish.
	^ lepiterChanges asArray , codeChanges asArray
	  , { (IceGitChange on: 'README.md') }
]

{ #category : #changes }
GtLepiterWorkingCopy >> changesToHeadUsingIndex [
	"Determine the changes between the current head commit of the repository and
	the working directory, by relying on the index."
	| changesBuilder |
	changesBuilder := GtGitLepiterChangesFromDeltasBuilder new
		databases: self databases;
		icebergRepository: self repository.
	
	^ changesBuilder changesFromDeltas: self icebergRepository getDeltasForFullDiff 
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
		self subscribeDatabase: aDatabase ]
]

{ #category : #actions }
GtLepiterWorkingCopy >> deleteDatabase: aDatabase [
	self assert: [ databases includes: aDatabase ].
	
	aDatabase removeFromParentDatabaseUpdatingProperties.
	databases remove: aDatabase ifAbsent: [ ].
	
	self unsubscribeDatabase: aDatabase.
	
	self assert: [ (databases includes: aDatabase) not ].
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
GtLepiterWorkingCopy >> gtAllLoadedExamples [
	^ self icebergWorkingCopy gtAllLoadedExamples
]

{ #category : #accessing }
GtLepiterWorkingCopy >> hasDatabases [
	^ databases size > 0
]

{ #category : #accessing }
GtLepiterWorkingCopy >> icebergRepository [

	^ icebergRepository
]

{ #category : #accessing }
GtLepiterWorkingCopy >> icebergRepository: anIcebergRepository [

	icebergRepository := anIcebergRepository
]

{ #category : #accessing }
GtLepiterWorkingCopy >> icebergWorkingCopy [
	^ self icebergRepository workingCopy
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

{ #category : #changes }
GtLepiterWorkingCopy >> loadLepiterChangesInWorkingCopyFrom: aTree [
	"I detect if the tree includes changes for Lepiter databases currently loaded. If yes I update those databases.
	I should be called after git operations that change the state of the git working copy on disk, to update the state
	of the working copy also inside the image, like after a branch is checkout."
	| visitor |
	
	visitor := GtGitLepiterImageWorkingCopyUpdateVisitor new
		lepiterWorkingCopy: self.
	aTree accept: visitor.
	^ visitor
]

{ #category : #merging }
GtLepiterWorkingCopy >> mergeCommit: aCommit [
	
	^ self icebergWorkingCopy workingCopyState 
		gtMergeCommit: aCommit forWorkingCopy: self 
]

{ #category : #callbacks }
GtLepiterWorkingCopy >> onDatabaseChanged: anAnnouncement [
	(anAnnouncement isKindOf: LeDatabaseUnloadAnnouncement) ifTrue: [ 
		databases remove: anAnnouncement database ifAbsent: [] ].

	Iceberg announcer announce:
		(IceRepositoryModified for: self repository)
]

{ #category : #callbacks }
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

	^ self icebergRepository
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
	^ GtLepiterDatabaseSnapshot 
		fromDatabase: database
		inRepository: self icebergRepository
]

{ #category : #'private - monticello' }
GtLepiterWorkingCopy >> snapshotForPackage: aPackage [ 
	^ self icebergWorkingCopy snapshotForPackage: aPackage 
]

{ #category : #actions }
GtLepiterWorkingCopy >> subscribeDatabase: aDatabase [
	aDatabase announcer weak
		when: LeAnnouncement
		send: #onDatabaseChanged:
		to: self.
	aDatabase monitor announcer weak
		when: LeLocalStoreMonitorSavedChanges
		send: #onDatabaseSaved:
		to: self
]

{ #category : #actions }
GtLepiterWorkingCopy >> unloadDatabase: aDatabase [
	aDatabase unload
]

{ #category : #actions }
GtLepiterWorkingCopy >> unsubscribeDatabase: aDatabase [
	aDatabase announcer unsubscribe: self.
	aDatabase monitor announcer unsubscribe: self.
	
]

{ #category : #actions }
GtLepiterWorkingCopy >> updateContentForDatabase: aDatabase [
	self assert: [ databases includes: aDatabase ].
	
	aDatabase monitor primitiveReloadWithPageDeletion 
]

{ #category : #actions }
GtLepiterWorkingCopy >> updateDatabases [
	| allDatabases |
	allDatabases := LeDatabasesRegistry defaultLogicalDatabase databases.
	
	self icebergRepository repositoryDirectory ifNotNil: [ 
		self databases: (allDatabases select: [ :aDatabase | 
			aDatabase storeLocation isFile and: 
				[ self icebergRepository repositoryDirectory 
			 	contains: aDatabase monitor localRoot ] ]) ]
]

{ #category : #initialization }
GtLepiterWorkingCopy >> useCheckAllStragegy [
	self lepiterChangesStragegy: GtLepiterWorkingCopyChangesCheckAllStrategy new
]

{ #category : #accessing }
GtLepiterWorkingCopy >> writerClass [
	^ self icebergWorkingCopy writerClass
]
