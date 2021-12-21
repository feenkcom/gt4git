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

{ #category : #testing }
GtLepiterWorkingCopy >> canRevertChanges [
	^ true
]

{ #category : #accessing }
GtLepiterWorkingCopy >> changesTo: aCommitish [
	| lepiterChanges codeChanges |
	lepiterChanges := self lepiterChangesTo: aCommitish.
	codeChanges := self icebergWorkingCopy changesTo: aCommitish.
	^ lepiterChanges asArray, codeChanges asArray
]

{ #category : #accessing }
GtLepiterWorkingCopy >> databases [

	^ databases
]

{ #category : #accessing }
GtLepiterWorkingCopy >> databases: anObject [

	databases := anObject
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
	^ FileSystem disk
]

{ #category : #accessing }
GtLepiterWorkingCopy >> getDeltasTree [
	| changedDatabases path |
	changedDatabases := OrderedDictionary new.
	self repository getDeltas do: [ :delta | 
		path := delta oldFile path.
		"TODO ignore properties and attachment files for now"
		(path basename = LepiterCoreDefaults databasePropertiesBasename or: [ 
			 path parent parent basename = 'attachments' ]) ifFalse: [ 
			self databases
				detect: [ :db | db localStoreRootDirectory asPath = path parent ]
				ifFound: [ :database | 
					changedDatabases
						at: database
						update: [ :aList | aList , { delta } ]
						initial: { delta } ] ] ].
	^ changedDatabases keys collect: [ :key | 
		  GtLepiterLocalDatabaseChange new
			  database: key;
			  pages: (changedDatabases at: key) ]
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

{ #category : #accessing }
GtLepiterWorkingCopy >> lepiterChangesTo: aCommitish [
	^ self lepiterChangesStragegy changesTo: aCommitish
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
