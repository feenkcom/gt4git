Class {
	#name : #GtIceLepiterExamples,
	#superclass : #Object,
	#instVars : [
		'lepiterDatabases',
		'repositories'
	],
	#category : #'GToolkit4Git-Lepiter-Examples'
}

{ #category : #assertions }
GtIceLepiterExamples >> assertAddedPageNode: aNode forPage: aPage [
	| operation definition |
	self 
		assertNode: aNode 
		withKey: (aPage database monitor pageFilename: aPage)
		withChildrenCount: 0.
		
	operation := aNode value .
	self assert: operation isAddition.
	
	definition := operation definition.
	self assert: definition name equals: aPage title.
]

{ #category : #examples }
GtIceLepiterExamples >> assertAddedPageNodes: pageNodes forPages: pages [
	| sortedPages sortedNodes |
	 sortedPages := pages sorted: [ :aPage | aPage uidString] ascending.
	 sortedNodes := pageNodes 
	 	sorted: [ :aPageNode | 
	 		aPageNode value definition pageUuid asString36 ] ascending.
	 self assert: sortedPages size equals: sortedNodes size.
	 1 to: sortedPages size do: [ :anIndex |
	 	self 
	 		assertAddedPageNode: (sortedNodes at: anIndex)
	 		forPage: (sortedPages at: anIndex) ].
]

{ #category : #assertions }
GtIceLepiterExamples >> assertDatabaseNode: aNode forDatabase: aDatabase withChildrenCount: anInteger [ 
	| operation definition |
	self 
		assertNode: aNode 
		withKey: aDatabase localStoreRootDirectory basename
		withChildrenCount: anInteger.
	
	operation := aNode value .
	self assert: operation isNoModification.
	self assert: operation name equals: aDatabase databaseName.
	self assert: operation key equals:  aDatabase localStoreRootDirectory basename.
	
	definition := operation definition.
	self assert: definition name equals: aDatabase databaseName.
	self assert: definition key equals:  aDatabase localStoreRootDirectory basename.
	self assert: definition databaseId notNil.
	self assert: definition class equals: GtLepiterDatabaseDefinition.
]

{ #category : #assertions }
GtIceLepiterExamples >> assertDiff: diff withChildrenCount: aChildrenCount andFullCount: allChildrenCount [

	self assert: diff isEmpty not.
	self assert: (diff tree withDeepCollect: #children) size equals: allChildrenCount.
	self assert: diff tree path equals: (RelativePath withAll: #(  )).
	self assert: diff tree children size equals: aChildrenCount
]

{ #category : #assertions }
GtIceLepiterExamples >> assertNode: aNode withKey: aKey withChildrenCount: anInteger [ 
	self assert: aNode key equals: aKey.
	self assert: aNode children size equals: anInteger.
]

{ #category : #assertions }
GtIceLepiterExamples >> assertPagesNode: aPagesNode withChildrenCount: anInteger [ 
	| operation |
	self 
		assertNode: aPagesNode 
		withKey: 'pages'
		withChildrenCount: anInteger.
		
	operation := aPagesNode value .
	self assert: operation isNoModification.
	self assert: operation name equals: 'pages'.
	self assert: operation key equals:  'pages'
]

{ #category : #'setUp-tearDown' }
GtIceLepiterExamples >> cleanUpRepositoriesAndDatabases [
	self detachLepiterDatabases.
	self removeRepositoriesAndCode.
]

{ #category : #'creation repositories' }
GtIceLepiterExamples >> createBasicIcebergRepositoryWithName: repositoryName [
	| iceRepository reposioryFolder |
	
	reposioryFolder := (FileLocator localDirectory / #gt4git / repositoryName) asFileReference.
	self assert: reposioryFolder exists not.
	self assert: (IceRepository registry anySatisfy: [ :aRepo | aRepo name = repositoryName ]) not.
	
	iceRepository := IceRepositoryCreator new
		location: reposioryFolder;
		subdirectory: 'src';
		ensureProjectFile;
		createNewRepositoryNamed: repositoryName.
	iceRepository workingCopy 
		commitWithMessage: 'Add properties and project files'.

	"Ideally do not register the repository with Iceberg.
	Registered for now to make ot easy to debug."
	IceRepository registerRepository: iceRepository. 
	
	"Ensure the repo was creates successfully"
	self assert: iceRepository isMissing not.
	self assert: iceRepository isModified not.
	self assert: iceRepository branch name equals: 'master'.
	self assert: iceRepository branch commits size equals: 1.
	
	^ iceRepository
]

{ #category : #'creation repositories' }
GtIceLepiterExamples >> createIcebergRepositoryNamed: aRepositoryName withLepiterDatabaseNamed: aDatabaseName [
	| iceRepository gtRepository database |
	
	(self repositories includesKey: aRepositoryName) 
		ifTrue: [ Error signal: 'Repository already present.' ].
	(self lepiterDatabases includesKey: aDatabaseName)
		ifTrue: [ Error signal: 'Database already present.' ].
		
	iceRepository := self createBasicIcebergRepositoryWithName: aRepositoryName.
	
	database := LeLocalStoreLoad current 
		loadAndMonitorFrom: iceRepository location / 'lepiter'
		saveDelay: 0 seconds.
	database databaseName: aDatabaseName.
	
	iceRepository index addPath: (database localStoreRootDirectory 
		relativeTo: iceRepository location).
	iceRepository commitWithMessage: 'Add lepiter database.'.
	
	"The current mechanism requires a database to be registered
	before creating the gt git repo, in order for the diff logic to work."
	LeDatabasesRegistry defaultLogicalDatabase addDB: database.
	
	gtRepository := GtGitRepository2 fromIcebergRepository: iceRepository.
	"self assertLepiterDatabase: database inFolderNamed: 'lepiter'."
	
	self repositories at: aRepositoryName put: gtRepository.
	self lepiterDatabases at: aDatabaseName put: database.
	
	^ gtRepository
]

{ #category : #'setUp-tearDown' }
GtIceLepiterExamples >> detachLepiterDatabases [
	self lepiterDatabases do: [ :aDatabase |
		LeDatabasesRegistry defaultLogicalDatabase removeDB: aDatabase ].
	self lepiterDatabases removeAll.
]

{ #category : #examples }
GtIceLepiterExamples >> gitRepositoryACommitNewAddedPage [
	<gtExample>
	<after: #cleanUpRepositoriesAndDatabases>
	| gtIceRepository |
	gtIceRepository := self gitRepositoryAWithNewAddedPage.
	
	gtIceRepository executeCommit: 'Add Page1'.
	
	self assert: gtIceRepository workingCopyDiff isEmpty.
	
	^ gtIceRepository
]

{ #category : #examples }
GtIceLepiterExamples >> gitRepositoryACommitTwoNewUnnamedAddedPage [
	<gtExample>
	<after: #cleanUpRepositoriesAndDatabases>
	| gtIceRepository |
	gtIceRepository := self gitRepositoryAWithTwoNewUnnamedAddedPage.
	
	gtIceRepository executeCommit: 'Add Two Pages'.
	
	self assert: gtIceRepository workingCopyDiff isEmpty.
	
	^ gtIceRepository
]

{ #category : #examples }
GtIceLepiterExamples >> gitRepositoryAWithEmptyLepiterDatabase [
	<gtExample>
	<after: #cleanUpRepositoriesAndDatabases>
	| gtIceRepository lepiterWorkingCopy |
	
	gtIceRepository := self 
		createIcebergRepositoryNamed: 'repo-a' 
		withLepiterDatabaseNamed: 'database-a'. 
	
	lepiterWorkingCopy := gtIceRepository lepiterWorkingCopy.
	self assert: lepiterWorkingCopy databases size equals: 1.
	self 
		assert: lepiterWorkingCopy databases first databaseName 
		equals: 'database-a'.
	self assert: lepiterWorkingCopy diffToReferenceCommit isEmpty.
	
	^ gtIceRepository
]

{ #category : #examples }
GtIceLepiterExamples >> gitRepositoryAWithNewAddedPage [
	<gtExample>
	<after: #cleanUpRepositoriesAndDatabases>
	| gtIceRepository targetDatabase newPage diff databaseNode pagesNode |
	gtIceRepository := self gitRepositoryAWithEmptyLepiterDatabase.
	targetDatabase := gtIceRepository lepiterWorkingCopy databases first.
	
	newPage := LePage named: 'Page1'.
	newPage addSnippet: (LeTextSnippet string: 'Block1').
	targetDatabase addPage: newPage.
	
	diff := gtIceRepository workingCopyDiff.
	self assertDiff: diff withChildrenCount: 1 andFullCount: 4.
	
	databaseNode := diff tree children first.
	self
		assertDatabaseNode: databaseNode
		forDatabase: targetDatabase
		withChildrenCount: 1.
		
	pagesNode := databaseNode children first.
	self assertPagesNode: pagesNode withChildrenCount: 1.
	self assertAddedPageNode: pagesNode children first forPage: newPage.
	
	^ gtIceRepository
]

{ #category : #examples }
GtIceLepiterExamples >> gitRepositoryAWithNewUnnamedAddedPage [
	<gtExample>
	<after: #cleanUpRepositoriesAndDatabases>
	| gtIceRepository targetDatabase newPage diff databaseNode pagesNode |
	gtIceRepository := self gitRepositoryAWithEmptyLepiterDatabase.
	targetDatabase := gtIceRepository lepiterWorkingCopy databases first.
	
	newPage := LePage unnamedPage.
	newPage addSnippet: (LeTextSnippet string: 'Block1 in Unnamed Page').
	targetDatabase addPage: newPage.
	
	diff := gtIceRepository workingCopyDiff.
	self assertDiff: diff withChildrenCount: 1 andFullCount: 4.
	
	databaseNode := diff tree children first.
	self
		assertDatabaseNode: databaseNode
		forDatabase: targetDatabase
		withChildrenCount: 1.
		
	pagesNode := databaseNode children first.
	self assertPagesNode: pagesNode withChildrenCount: 1.
	self assertAddedPageNode: pagesNode children first forPage: newPage.
	
	^ gtIceRepository
]

{ #category : #examples }
GtIceLepiterExamples >> gitRepositoryAWithTwoNewUnnamedAddedPage [
	<gtExample>
	<after: #cleanUpRepositoriesAndDatabases>
	| gtIceRepository targetDatabase newPage1 newPage2 diff databaseNode pagesNode |
	gtIceRepository := self gitRepositoryAWithEmptyLepiterDatabase.
	targetDatabase := gtIceRepository lepiterWorkingCopy databases first.
	
	newPage1 := LePage unnamedPage.
	newPage1 addSnippet: (LeTextSnippet string: 'Block1 in Unnamed Page2').
	targetDatabase addPage: newPage1.
	
	newPage2 := LePage unnamedPage.
	newPage2 addSnippet: (LeTextSnippet string: 'Block1 in Unnamed Page2').
	targetDatabase addPage: newPage2.
	
	diff := gtIceRepository workingCopyDiff.
	self assertDiff: diff withChildrenCount: 1 andFullCount: 5.
	
	databaseNode := diff tree children first.
	self
		assertDatabaseNode: databaseNode
		forDatabase: targetDatabase
		withChildrenCount: 1.
		
	pagesNode := databaseNode children first.
	self assertPagesNode: pagesNode withChildrenCount: 2.
	self 
		assertAddedPageNodes: pagesNode children 
		forPages: {newPage1 . newPage2}.
	
	^ gtIceRepository
]

{ #category : #accessing }
GtIceLepiterExamples >> lepiterDatabases [ 
	^ lepiterDatabases ifNil: [ 
		lepiterDatabases := IdentityDictionary new ]
]

{ #category : #'setUp-tearDown' }
GtIceLepiterExamples >> removeRepositoriesAndCode [
	self repositories do: [ :anIcebergRepository |
		IceRepository registry 
			detect: [ :aRepo | aRepo name = anIcebergRepository name ] 
			ifFound: [ :aRepo | aRepo forget ].

		"Remove all packages from the system"
		anIcebergRepository workingCopy packages do: [ :aPackage |
			SystemAnnouncer uniqueInstance suspendAllWhile: [ 
				GtPharoCodeModifier removePackageNamed: aPackage name ] ].

		"Delete all files from disk related to this repository"
		anIcebergRepository workingCopy fileSystem ensureDeleteAll ].
	self repositories removeAll.
]

{ #category : #accessing }
GtIceLepiterExamples >> repositories [ 
	^ repositories ifNil: [ 
		repositories := IdentityDictionary new ]
]
