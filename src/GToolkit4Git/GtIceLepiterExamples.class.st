Class {
	#name : #GtIceLepiterExamples,
	#superclass : #Object,
	#instVars : [
		'lepiterDatabases',
		'repositories'
	],
	#category : #'GToolkit4Git-Lepiter-Examples'
}

{ #category : #'assertions - pages' }
GtIceLepiterExamples >> assertAddedPageNodes: pageNodes forPages: pages [
	| sortedPages sortedNodes |
	 sortedPages := pages sorted: [ :aPage | aPage uidString] ascending.
	 sortedNodes := pageNodes 
	 	sorted: [ :aPageNode | 
	 		aPageNode value definition pageUuid asString36 ] ascending.
	 self assert: sortedPages size equals: sortedNodes size.
	 1 to: sortedPages size do: [ :anIndex |
		self 
			assertPageNode: (sortedNodes at: anIndex)  
			fromDatabase: (sortedPages at: anIndex)  database 
			forPage: (sortedPages at: anIndex)  
			withOperation:  #add ].
]

{ #category : #'assertions - attachments' }
GtIceLepiterExamples >> assertAttachmentContentNode: aNode forFile: aFile withOperation: aSymbol [
	| operation definition |
	
	self 
		assertNode: aNode 
		withKey: aFile basename
		withChildrenCount: 0.
		
	operation := aNode value.
	self assertOperation: aSymbol for: operation.
	self assert: operation name equals: aFile basename.
	self assert: operation key equals: aFile basename.
	
	definition := operation definition.
	self assert: definition name equals: aFile basename.
	self assert: definition key equals: aFile basename.
	self assert: definition class equals: GtLepiterAttachmentFileDefinition.
]

{ #category : #'assertions - attachments' }
GtIceLepiterExamples >> assertAttachmentNode: aNode fromDatabase: aDatabase forDirectory: aDirectory withOperation: aSymbol [
	self assertBasicAttachmentNode: aNode forDirectory: aDirectory withOperation: aSymbol.
	self 
		assertAttachmentPropertiesNode: (aNode children 
			detect: [ :aChildNode | 
				aChildNode value definition isAttachmentPropertiesDefinition ])
		forFile: (aDirectory filesMatching: LeAttachment basename) first
		withOperation: aSymbol.
	self 
		assertAttachmentContentNode: (aNode children 
			detect: [ :aChildNode | aChildNode value definition  isAttachmentFileDefinition ])
		forFile: (aDirectory files reject: [ :aFile | 
			aFile basename = LeAttachment basename]) first
		withOperation: aSymbol.
]

{ #category : #'assertions - attachments' }
GtIceLepiterExamples >> assertAttachmentPropertiesNode: aNode forFile: aFile withOperation: aSymbol [
	| operation definition |
	
	self 
		assertNode: aNode 
		withKey: aFile basename
		withChildrenCount: 0.
		
	operation := aNode value.
	self assertOperation: aSymbol for: operation.
	self assert: operation name equals: aFile basename.
	self assert: operation key equals: aFile basename.
	
	definition := operation definition.
	self assert: definition name equals: aFile basename.
	self assert: definition key equals: aFile basename.
	self assert: definition class equals: GtLepiterAttachmentPropertiesDefinition.
]

{ #category : #'assertions - attachments' }
GtIceLepiterExamples >> assertAttachmentsNode: aPagesNode withChildrenCount: anInteger [ 
	| operation |
	self 
		assertNode: aPagesNode 
		withKey: 'attachments'
		withChildrenCount: anInteger.
		
	operation := aPagesNode value .
	self assert: operation isNoModification.
	self assert: operation name equals: 'attachments'.
	self assert: operation key equals: 'attachments'
]

{ #category : #'assertions - attachments' }
GtIceLepiterExamples >> assertBasicAttachmentNode: aNode forDirectory: aDirectory withOperation: aSymbol [
	| operation definition |
	
	self 
		assertNode: aNode 
		withKey: aDirectory basename
		withChildrenCount: 2.
		
	operation := aNode value.
	self assertOperation: aSymbol for: operation.
	self assert: operation name equals: aDirectory basename.
	self assert: operation key equals: aDirectory basename.
	
	definition := operation definition.
	self assert: definition name equals: aDirectory basename.
	self assert: definition key equals: aDirectory basename.
	self assert: definition class equals: GtLepiterAttachmentDefinition.
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
GtIceLepiterExamples >> assertDatabasePropertiesNode: aNode forDatabase: aDatabase withOperation: aSymbol [
	| operation definition |
	self 
		assertNode: aNode 
		withKey: LepiterCoreDefaults databasePropertiesBasename
		withChildrenCount: 0.
	
	operation := aNode value .
	self assertOperation: aSymbol for: operation.
	self assert: operation name equals: LepiterCoreDefaults databasePropertiesBasename.
	self assert: operation key equals: LepiterCoreDefaults databasePropertiesBasename.
	
	definition := operation definition.
	self assert: definition name equals: LepiterCoreDefaults databasePropertiesBasename.
	self assert: definition key equals: LepiterCoreDefaults databasePropertiesBasename.
	self assert: definition fileName equals: LepiterCoreDefaults databasePropertiesBasename.
	self assert: definition class equals: GtLepiterDatabasePropertiesDefinition.
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

{ #category : #'assertions - pages' }
GtIceLepiterExamples >> assertOneAddedPage: aPage inRepository: gtIceRepository [
	self 
		assertOnePage: aPage 
		inRepository: gtIceRepository 
		withOperation: #add
]

{ #category : #'assertions - pages' }
GtIceLepiterExamples >> assertOneModifiedPage: aPage inRepository: gtIceRepository [
	self 
		assertOnePage: aPage 
		inRepository: gtIceRepository 
		withOperation: #modify
]

{ #category : #'assertions - pages' }
GtIceLepiterExamples >> assertOnePage: aPage fromDatabse: aDatabase inRepository: gtIceRepository withOperation: aSymbol [
	| diff databaseNode pagesNode |
	diff := gtIceRepository workingCopyDiff.
	self assertDiff: diff withChildrenCount: 1 andFullCount: 4.
	
	databaseNode := diff tree children first.
	self
		assertDatabaseNode: databaseNode
		forDatabase: aDatabase
		withChildrenCount: 1.
		
	pagesNode := databaseNode children first.
	self assertPagesNode: pagesNode withChildrenCount: 1.
	self 
		assertPageNode: pagesNode children first 
		fromDatabase: aDatabase
		forPage: aPage 
		withOperation: aSymbol.
]

{ #category : #'assertions - pages' }
GtIceLepiterExamples >> assertOnePage: aPage inRepository: gtIceRepository withOperation: aSymbol [
	self 
		assertOnePage: aPage 
		fromDatabse: aPage database
		inRepository: gtIceRepository 
		withOperation: aSymbol
]

{ #category : #'assertions - pages' }
GtIceLepiterExamples >> assertOneRemovedPage: aPage fromDatabase: aDatabase inRepository: gtIceRepository [
	self 
		assertOnePage: aPage 
		fromDatabse: aDatabase
		inRepository: gtIceRepository 
		withOperation: #remove
]

{ #category : #assertions }
GtIceLepiterExamples >> assertOperation: aSymbol for: anOperation [
	aSymbol = #add 
		ifTrue: [ ^ self assert: anOperation isAddition ].
	aSymbol = #modify 
		ifTrue: [ ^ self assert: anOperation isModification ].
	aSymbol = #remove 
		ifTrue: [ ^ self assert: anOperation isRemoval ].
	
	Error signal: 'Unknown operation'.
]

{ #category : #'assertions - pages' }
GtIceLepiterExamples >> assertPageNode: aNode fromDatabase: aDatabase forPage: aPage withOperation: aSymbol [
	| operation definition pageName |
	pageName := aDatabase monitor pageFilename: aPage.
	self 
		assertNode: aNode 
		withKey: pageName
		withChildrenCount: 0.
		
	operation := aNode value.
	self assertOperation: aSymbol for: operation.
	self assert: operation name equals: aPage title.
	self assert: operation key equals: pageName.
	
	definition := operation definition.
	self assert: definition name equals: aPage title.
	self assert: definition key equals: pageName.
	self assert: definition fileName equals: pageName.
	self assert: definition pageUuid equals: aPage uid.
	self assert: definition class equals: GtLepiterPageDefinition.
]

{ #category : #'assertions - pages' }
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
	self 
		assert: reposioryFolder exists not 
		description: 'Repository folder should not exist'.
	self 
		assert: (IceRepository registry 
			anySatisfy: [ :aRepo | aRepo name = repositoryName ]) not
		description: 'Repository should not be registered'.
	
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
	self assert: iceRepository isMissing not description: 'Repository is present'.
	self assert: iceRepository isModified not description: 'Repository is not modified'.
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
	
	"The current mechanism requires a database to be registered
	before creating the gt git repo, in order for the diff logic to work."
	LeDatabasesRegistry defaultLogicalDatabase addDB: database.
	
	gtRepository := GtGitRepository2 fromIcebergRepository: iceRepository.
	"self assertLepiterDatabase: database inFolderNamed: 'lepiter'."
	
	self repositories at: aRepositoryName put: gtRepository.
	self lepiterDatabases at: aDatabaseName put: database.
	
	^ gtRepository
]

{ #category : #utils }
GtIceLepiterExamples >> createNewPageWithAttachmentIn: aDatabase [
	<gtIgnoreConstraint: #GtRBAcceptVisitorCalledFromNonVisitingMethods>
	| newPage textSnippet visitor |
	newPage := LePage named: 'Page1'.
	textSnippet := LeTextSnippet
		string: '![](https://feenk.com/assets/pictures/feenk.png)'.
	newPage addSnippet: textSnippet.
	aDatabase addPage: newPage.

	visitor := LeImageImportVisitor new.
	aDatabase acceptVisitor: visitor.
	
	self assert: visitor addedImages size equals: 1.
	visitor cleanUp.
	
	^ newPage
]

{ #category : #'setUp-tearDown' }
GtIceLepiterExamples >> detachLepiterDatabases [
	self lepiterDatabases do: [ :aDatabase |
		LeDatabasesRegistry defaultLogicalDatabase removeDB: aDatabase ].
	self lepiterDatabases removeAll.
]

{ #category : #'examples - single page' }
GtIceLepiterExamples >> gitRepositoryACommitEditedPage [
	<gtExample>
	<after: #cleanUpRepositoriesAndDatabases>
	| gtIceRepository |
	gtIceRepository := self gitRepositoryAEditExistingPage.
	
	gtIceRepository executeCommit: 'Edit Page1'.
	
	self assert: gtIceRepository repository  getDeltasForFullDiff isEmpty.
	self assert: gtIceRepository workingCopyDiff isEmpty.
	
	^ gtIceRepository
]

{ #category : #'examples - single page' }
GtIceLepiterExamples >> gitRepositoryACommitNewAddedPage [
	<gtExample>
	<after: #cleanUpRepositoriesAndDatabases>
	| gtIceRepository |
	gtIceRepository := self gitRepositoryAWithNewAddedPage.
	
	gtIceRepository executeCommit: 'Add Page1'.
	
	self assert: gtIceRepository workingCopyDiff isEmpty.
	
	^ gtIceRepository
]

{ #category : #'examples - single page' }
GtIceLepiterExamples >> gitRepositoryACommitNewUnnamedAddedPage [
	<gtExample>
	<after: #cleanUpRepositoriesAndDatabases>
	| gtIceRepository |
	gtIceRepository := self gitRepositoryAWithNewUnnamedAddedPage.
	
	gtIceRepository executeCommit: 'Add Page1 unnamed'.
	
	self assert: gtIceRepository workingCopyDiff isEmpty.
	
	^ gtIceRepository
]

{ #category : #'examples - single page' }
GtIceLepiterExamples >> gitRepositoryACommitRemovedPage [
	<gtExample>
	<after: #cleanUpRepositoriesAndDatabases>
	| gtIceRepository |
	gtIceRepository := self gitRepositoryARemoveExistingPage.
	
	gtIceRepository executeCommit: 'Remove Page1'.
	
	self assert: gtIceRepository workingCopyDiff isEmpty.
	
	^ gtIceRepository
]

{ #category : #'examples - pages' }
GtIceLepiterExamples >> gitRepositoryACommitTwoNewUnnamedAddedPage [
	<gtExample>
	<after: #cleanUpRepositoriesAndDatabases>
	| gtIceRepository |
	gtIceRepository := self gitRepositoryAWithTwoNewUnnamedAddedPage.
	
	gtIceRepository executeCommit: 'Add Two Pages'.
	
	self assert: gtIceRepository workingCopyDiff isEmpty.
	
	^ gtIceRepository
]

{ #category : #'examples - single page' }
GtIceLepiterExamples >> gitRepositoryAEditExistingPage [
	<gtExample>
	<after: #cleanUpRepositoriesAndDatabases>
	| gtIceRepository targetDatabase targetPage |
	gtIceRepository := self gitRepositoryACommitNewAddedPage.
	targetDatabase := gtIceRepository lepiterWorkingCopy databases first.
	
	targetPage := targetDatabase pageNamed: 'Page1'.
	targetPage children first updateString: 'Updated Snippet1 Text'.

	self assertOneModifiedPage: targetPage inRepository: gtIceRepository.
	
	^ gtIceRepository
]

{ #category : #'examples - single page' }
GtIceLepiterExamples >> gitRepositoryARemoveExistingPage [
	<gtExample>
	<after: #cleanUpRepositoriesAndDatabases>
	| gtIceRepository targetDatabase targetPage |
	gtIceRepository := self gitRepositoryACommitNewAddedPage.
	targetDatabase := gtIceRepository lepiterWorkingCopy databases first.
	
	targetPage := targetDatabase pageNamed: 'Page1'.
	targetPage removeSelf.

	self 
		assertOneRemovedPage: targetPage 
		fromDatabase: targetDatabase 
		inRepository: gtIceRepository.
	
	^ gtIceRepository
]

{ #category : #examples }
GtIceLepiterExamples >> gitRepositoryAWithEmptyCommitedLepiterDatabase [
	<gtExample>
	<after: #cleanUpRepositoriesAndDatabases>
	| gtIceRepository |
	
	gtIceRepository := self gitRepositoryAWithNewEmptyNotCommitedLepiterDatabase. 
	gtIceRepository executeCommit: 'Add Two Pages'.
	
	self assert: gtIceRepository workingCopyDiff isEmpty.
	
	^ gtIceRepository
]

{ #category : #'examples - single page' }
GtIceLepiterExamples >> gitRepositoryAWithNewAddedPage [
	<gtExample>
	<after: #cleanUpRepositoriesAndDatabases>
	| gtIceRepository targetDatabase newPage |
	gtIceRepository := self gitRepositoryAWithEmptyCommitedLepiterDatabase.
	targetDatabase := gtIceRepository lepiterWorkingCopy databases first.
	
	newPage := LePage named: 'Page1'.
	newPage addSnippet: (LeTextSnippet string: 'Snippet1').
	targetDatabase addPage: newPage.
	
	self assertOneAddedPage: newPage inRepository: gtIceRepository.
	
	^ gtIceRepository
]

{ #category : #examples }
GtIceLepiterExamples >> gitRepositoryAWithNewEmptyNotCommitedLepiterDatabase [
	<gtExample>
	<after: #cleanUpRepositoriesAndDatabases>
	| gtIceRepository lepiterWorkingCopy targetDatabase diff databaseNode |
	
	gtIceRepository := self 
		createIcebergRepositoryNamed: 'repo-a' 
		withLepiterDatabaseNamed: 'database-a'. 
	
	lepiterWorkingCopy := gtIceRepository lepiterWorkingCopy.
	self assert: lepiterWorkingCopy databases size equals: 1.
	targetDatabase := lepiterWorkingCopy databases first.
	self 
		assert: lepiterWorkingCopy databases first databaseName 
		equals: 'database-a'.
	
	diff := lepiterWorkingCopy diffToReferenceCommit.
	self assert: diff isEmpty not.

	self assertDiff: diff withChildrenCount: 1 andFullCount: 3.
	
	databaseNode := diff tree children first.
	self
		assertDatabaseNode: databaseNode
		forDatabase: targetDatabase
		withChildrenCount: 1.
	self
		assertDatabasePropertiesNode: databaseNode children first
		forDatabase: targetDatabase
		withOperation: #add.
	
	^ gtIceRepository
]

{ #category : #'examples - attachments' }
GtIceLepiterExamples >> gitRepositoryAWithNewPageWithAttachment [
	<gtExample>
	<after: #cleanUpRepositoriesAndDatabases>
	| gtIceRepository targetDatabase newPage diff databaseNode pagesNode attachmentsNode |
	gtIceRepository := self gitRepositoryAWithEmptyCommitedLepiterDatabase.
	targetDatabase := gtIceRepository lepiterWorkingCopy databases first.
	
	newPage := self createNewPageWithAttachmentIn: targetDatabase.
	
	diff := gtIceRepository workingCopyDiff.
	self assertDiff: diff withChildrenCount: 1 andFullCount: 8.
	
	databaseNode := diff tree children first.
	self
		assertDatabaseNode: databaseNode
		forDatabase: targetDatabase
		withChildrenCount: 2.
	pagesNode := databaseNode children second.
	self assertPagesNode: pagesNode withChildrenCount: 1.
	self 
		assertPageNode: pagesNode children first 
		fromDatabase: targetDatabase
		forPage: newPage 
		withOperation: #add.
	
	attachmentsNode := databaseNode children first.
	self assertAttachmentsNode: attachmentsNode withChildrenCount: 1.
	self 
		assertAttachmentNode: attachmentsNode children first 
		fromDatabase: targetDatabase
		forDirectory: targetDatabase attachmentDirectories first 
		withOperation: #add.
	
	^ gtIceRepository
]

{ #category : #'examples - pages' }
GtIceLepiterExamples >> gitRepositoryAWithNewUnnamedAddedPage [
	<gtExample>
	<after: #cleanUpRepositoriesAndDatabases>
	| gtIceRepository targetDatabase newPage deltas |
	gtIceRepository := self gitRepositoryAWithEmptyCommitedLepiterDatabase.
	targetDatabase := gtIceRepository lepiterWorkingCopy databases first.
	
	newPage := LePage unnamedPage.
	newPage addSnippet: (LeTextSnippet string: 'Block1 in Unnamed Page').
	targetDatabase addPage: newPage.
	
	deltas := gtIceRepository repository getDeltasForFullDiff.
	self assert: deltas size equals: 1.
	
	self assertOneAddedPage: newPage inRepository: gtIceRepository.
	
	^ gtIceRepository
]

{ #category : #'examples - pages' }
GtIceLepiterExamples >> gitRepositoryAWithTwoNewUnnamedAddedPage [
	<gtExample>
	<after: #cleanUpRepositoriesAndDatabases>
	| gtIceRepository targetDatabase newPage1 newPage2 diff databaseNode pagesNode deltas |
	gtIceRepository := self gitRepositoryAWithEmptyCommitedLepiterDatabase.
	targetDatabase := gtIceRepository lepiterWorkingCopy databases first.
	
	newPage1 := LePage unnamedPage.
	newPage1 addSnippet: (LeTextSnippet string: 'Block1 in Unnamed Page2').
	targetDatabase addPage: newPage1.
	
	newPage2 := LePage unnamedPage.
	newPage2 addSnippet: (LeTextSnippet string: 'Block1 in Unnamed Page2').
	targetDatabase addPage: newPage2.
	
	deltas := gtIceRepository repository getDeltasForFullDiff.
	self assert: deltas size equals: 2.
	
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
