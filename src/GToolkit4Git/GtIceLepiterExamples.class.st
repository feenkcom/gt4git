Class {
	#name : #GtIceLepiterExamples,
	#superclass : #Object,
	#instVars : [
		'lepiterDatabases',
		'repositories'
	],
	#category : #'GToolkit4Git-Examples'
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
GtIceLepiterExamples >> assertFolderNode: aNode forName: aFolderName withChildrenCount: anInteger [ 
	| operation definition |
	self 
		assertNode: aNode 
		withKey: aFolderName
		withChildrenCount: anInteger.
	
	operation := aNode value .
	self assert: operation isNoModification.
	self assert: operation name equals: aFolderName.
	self assert: operation key equals: aFolderName.
	
	definition := operation definition.
	self assert: definition name equals: aFolderName.
	self assert: definition key equals: aFolderName.
	self assert: definition isDirectoryDefinition.
]

{ #category : #assertions }
GtIceLepiterExamples >> assertNoChangesInRepository: aGtIceRepository [
	self 
		assert: aGtIceRepository getDeltasForFullDiff isEmpty
		description: 'There should be no deltas'.
	self 
		assert: aGtIceRepository workingCopyDiff isEmpty
		description: 'The diff with the working copy should be empty.'.
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
	| iceRepository repositoryFolder |
	(self repositories includesKey: repositoryName)
		ifTrue: [ Error signal: 'Repository already present.' ].

	repositoryFolder := self randomTempFolderFor: repositoryName.
	self
		assert: repositoryFolder exists not
		description: 'Repository folder should not exist'.
	self
		assert: (IceRepository registry anySatisfy: [ :aRepo | aRepo name = repositoryName ])
				not
		description: 'Repository should not be registered'.

	iceRepository := IceRepositoryCreator new
			location: repositoryFolder;
			subdirectory: 'src';
			ensureProjectFile;
			commitishName: self mainBranchName;
			createNewRepositoryNamed: repositoryName.

	iceRepository workingCopy commitWithMessage: 'Add properties and project files'.	"Ideally do not register the repository with Iceberg.
	Registered for now to make ot easy to debug."
	IceRepository registerRepository: iceRepository.
	self repositories at: repositoryName put: iceRepository.	"Ensure the repo was creates successfully"
	self assert: iceRepository isMissing not description: 'Repository is present'.
	self
		assert: iceRepository isModified not
		description: 'Repository is not modified'.
	self assert: iceRepository branch commits size equals: 1.

	^ iceRepository
]

{ #category : #'creation repositories' }
GtIceLepiterExamples >> createDatabaseNamed: aDatabaseName atLocation: aPathString inIcebergRepository: iceRepository [
	| database |
	
	database := LeLocalStoreLoad current 
		loadAndMonitorFrom: (self 
			databaseLocationForRepository: iceRepository
			atLocation: aPathString)
		saveDelay: 0 seconds.
	database databaseName: aDatabaseName.
	self lepiterDatabases at: aDatabaseName put: database.
	
	^ database
]

{ #category : #'creation repositories' }
GtIceLepiterExamples >> createDatabaseNamed: aDatabaseName inIcebergRepository: iceRepository [
	^ self 
		createDatabaseNamed: aDatabaseName 
		atLocation: self defaultDatabasePathString
		inIcebergRepository: iceRepository
]

{ #category : #'creation repositories' }
GtIceLepiterExamples >> createIcebergRepositoryNamed: aRepositoryName withLepiterDatabaseNamed: aDatabaseName [
	^ self 
		createIcebergRepositoryNamed: aRepositoryName 
		withLepiterDatabaseNamed: aDatabaseName 
		atLocation: self defaultDatabasePathString
]

{ #category : #'creation repositories' }
GtIceLepiterExamples >> createIcebergRepositoryNamed: aRepositoryName withLepiterDatabaseNamed: aDatabaseName atLocation: aPathString [
	| iceRepository gtRepository database |
	
	(self lepiterDatabases includesKey: aDatabaseName)
		ifTrue: [ Error signal: 'Database already present.' ].
		
	iceRepository := self createBasicIcebergRepositoryWithName: aRepositoryName.
	database := self 
		createDatabaseNamed: aDatabaseName 
		atLocation: aPathString
		inIcebergRepository: iceRepository.
	
	"The current mechanism requires a database to be registered
	before creating the gt git repo, in order for the diff logic to work."
	"LeDatabasesRegistry defaultLogicalDatabase addDB: database."
	
	gtRepository := GtGitRepository fromIcebergRepository: iceRepository.
	gtRepository lepiterWorkingCopy: (GtLepiterWorkingCopy new
		icebergRepository: iceRepository; 
		databases: { database }).
	
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

{ #category : #'creation repositories' }
GtIceLepiterExamples >> databaseLocationForRepository: iceRepository [
	^ self 
		databaseLocationForRepository: iceRepository 
		atLocation: self defaultDatabasePathString
]

{ #category : #'creation repositories' }
GtIceLepiterExamples >> databaseLocationForRepository: iceRepository atLocation: aPathString [
	^ iceRepository location / aPathString
]

{ #category : #'accessing - names' }
GtIceLepiterExamples >> defaultDatabasePathString [
	^ 'lepiter'
]

{ #category : #'setUp-tearDown' }
GtIceLepiterExamples >> detachLepiterDatabases [
	"self lepiterDatabases do: [ :aDatabase |
		LeDatabasesRegistry defaultLogicalDatabase removeDB: aDatabase ]."
	
	self lepiterDatabases removeAll.
]

{ #category : #'examples - checkout' }
GtIceLepiterExamples >> gitRepositoryACheckoutNewBranch [
	<gtExample>
	
	| gtIceRepository targetDatabase |
	gtIceRepository := self gitRepositoryACommitNewAddedPage.
	
	gtIceRepository 
		gtLepiterAwareCheckoutBranch: self secondaryBranchName.
		
	self assert: gtIceRepository icebergRepository branchName equals: self secondaryBranchName.
	targetDatabase := gtIceRepository lepiterWorkingCopy databases anyOne.
	
	self assertNoChangesInRepository:  gtIceRepository.
	
	^ gtIceRepository
]

{ #category : #'examples - single page' }
GtIceLepiterExamples >> gitRepositoryACommitEditedPage [
	<gtExample>
	<after: #cleanUpRepositoriesAndDatabases>
	| gtIceRepository |
	gtIceRepository := self gitRepositoryAEditExistingPage.
	
	gtIceRepository executeCommit: 'Edit Page1'.
	
	self assert: gtIceRepository getDeltasForFullDiff isEmpty.
	self assert: gtIceRepository workingCopyDiff isEmpty.
	
	^ gtIceRepository
]

{ #category : #'examples - checkout' }
GtIceLepiterExamples >> gitRepositoryACommitEditedPageInSecondBranch [
	<gtExample>
	
	| gtIceRepository targetDatabase existingPage |
	gtIceRepository := self gitRepositoryACheckoutNewBranch.
	targetDatabase := gtIceRepository lepiterWorkingCopy databases anyOne.
	
	existingPage := targetDatabase pageNamed: 'Page1'.
	existingPage addSnippet: (LeTextSnippet string: 'Snippet2-SecondModified').
	self 
		assertOneModifiedPage: existingPage 
		inRepository: gtIceRepository.
	
	gtIceRepository executeCommit: 'Edit Page1'.
	self assertNoChangesInRepository:  gtIceRepository.
	self assert: targetDatabase pageCount equals: 1.
	self assert: existingPage children size equals: 2.
	
	^ gtIceRepository
]

{ #category : #'examples - checkout' }
GtIceLepiterExamples >> gitRepositoryACommitEditedPageInSecondBranch_checkoutMainBranch [
	<gtExample>
	
	| gtIceRepository targetDatabase targetPage beforeBranches afterBranches |
	gtIceRepository := self gitRepositoryACommitEditedPageInSecondBranch.
	targetDatabase := gtIceRepository lepiterWorkingCopy databases anyOne.
	
	beforeBranches := gtIceRepository repository allBranches copy.
	self assert: beforeBranches size equals: 2.
	
	gtIceRepository 
		gtLepiterAwareCheckoutBranch: self mainBranchName.
	self assertNoChangesInRepository:  gtIceRepository.
	
	afterBranches :=  gtIceRepository repository allBranches copy.
	self assert: beforeBranches size equals: 2.
	
	targetPage := targetDatabase pageNamed: 'Page1'.
	self assert: targetDatabase pageCount equals: 1.
	self assert: targetPage children size equals: 1.
	
	^ gtIceRepository
]

{ #category : #'examples - checkout' }
GtIceLepiterExamples >> gitRepositoryACommitEditedPageInSecondBranch_checkoutMainBranch_commitInMainBranch [
	<gtExample>
	
	| gtIceRepository targetDatabase targetPage |
	gtIceRepository := self gitRepositoryACommitEditedPageInSecondBranch_checkoutMainBranch.
	targetDatabase := gtIceRepository lepiterWorkingCopy databases anyOne.

	targetPage := targetDatabase pageNamed: 'Page1'.
	targetPage addSnippet: (LeTextSnippet string: 'Snippet2-MainModified').
	self 
		assertOneModifiedPage: targetPage 
		inRepository: gtIceRepository.
		
	gtIceRepository executeCommit: 'Edit Page1'.
	self assertNoChangesInRepository:  gtIceRepository.
	
	self assert: targetDatabase pageCount equals: 1.
	self assert: targetPage children size equals: 2.
	
	^ gtIceRepository
]

{ #category : #'examples - merge' }
GtIceLepiterExamples >> gitRepositoryACommitEditedPageInSecondBranch_checkoutMainBranch_commitInMainBranch_mergeSecondBranchWithConflict [
	<gtExample>
	
	| gtIceRepository targetDatabase mergeException mergeAction conflicts |
	gtIceRepository := self gitRepositoryACommitEditedPageInSecondBranch_checkoutMainBranch_commitInMainBranch.
	targetDatabase := gtIceRepository lepiterWorkingCopy databases anyOne.

	mergeException := nil.
	[ 
		gtIceRepository lepiterWorkingCopy 
			mergeCommit: (gtIceRepository icebergRepository 
				branchNamed: self secondaryBranchName) commit 
	] on: IceMergeResolutionRequest do: [ :anException | mergeException := anException ].
	self assert: mergeException notNil.
	self assert: mergeException merge notNil.
	
	self assertNoChangesInRepository: gtIceRepository.
	
	mergeAction := mergeException merge.
	self assert: mergeAction unresolvedConflictCount equals: 1.
	conflicts := mergeAction gtConflicts first.
	
	^ mergeAction
]

{ #category : #'examples - checkout' }
GtIceLepiterExamples >> gitRepositoryACommitEditedPageInSecondBranch_checkoutMainBranch_mergeSecondBranch [
	<gtExample>
	
	| gtIceRepository targetDatabase targetPage |
	gtIceRepository := self gitRepositoryACommitEditedPageInSecondBranch_checkoutMainBranch.
	targetDatabase := gtIceRepository lepiterWorkingCopy databases anyOne.
	
	gtIceRepository lepiterWorkingCopy 
		mergeCommit: (gtIceRepository icebergRepository 
			branchNamed: self secondaryBranchName) commit.
	self assertNoChangesInRepository:  gtIceRepository.
	
	targetPage := targetDatabase pageNamed: 'Page1'.
	self assert: targetPage children size equals: 2.
	self assert: targetPage children first string equals: 'Snippet1'.
	self assert: targetPage children second string equals: 'Snippet2-SecondModified'.
	self assert: targetDatabase pageCount equals: 1.
	
	^ gtIceRepository
]

{ #category : #'examples - checkout' }
GtIceLepiterExamples >> gitRepositoryACommitEditedPageInSecondBranch_checkoutMainBranch_nonConflictingCommitInMainBranch [
	<gtExample>
	
	| gtIceRepository targetDatabase newPage |
	gtIceRepository := self gitRepositoryACommitEditedPageInSecondBranch_checkoutMainBranch.
	targetDatabase := gtIceRepository lepiterWorkingCopy databases anyOne.

	newPage := LePage named: 'Page2'.
	newPage addSnippet: (LeTextSnippet string: 'Snippet2-1').
	targetDatabase addPage: newPage.
	
	self assertOneAddedPage: newPage inRepository: gtIceRepository.
	
	gtIceRepository executeCommit: 'Add Page2'.
	self assertNoChangesInRepository:  gtIceRepository.
	
	self assert: targetDatabase pageCount equals: 2.
	self assert: newPage children size equals: 1.
	
	^ gtIceRepository
]

{ #category : #'examples - merge' }
GtIceLepiterExamples >> gitRepositoryACommitEditedPageInSecondBranch_checkoutMainBranch_nonConflictingCommitInMainBranch_mergeSecondBranch [
	<gtExample>
	
	| gtIceRepository targetDatabase |
	gtIceRepository := self gitRepositoryACommitEditedPageInSecondBranch_checkoutMainBranch_nonConflictingCommitInMainBranch.
	targetDatabase := gtIceRepository lepiterWorkingCopy databases anyOne.

	gtIceRepository lepiterWorkingCopy 
		mergeCommit: (gtIceRepository icebergRepository 
			branchNamed: self secondaryBranchName) commit.
	
	self assertNoChangesInRepository: gtIceRepository.
	self assert: targetDatabase pageCount equals: 2.
	self assert: (targetDatabase hasPageNamed: 'Page1').
	self assert: (targetDatabase hasPageNamed: 'Page2').
	self assert: (targetDatabase pageNamed: 'Page1') children first string equals: 'Snippet1'.
	self assert: (targetDatabase pageNamed: 'Page1') children second string equals: 'Snippet2-SecondModified'.
	self assert: (targetDatabase pageNamed: 'Page2') children first string equals: 'Snippet2-1'.
	
	^ gtIceRepository
]

{ #category : #'examples - single page' }
GtIceLepiterExamples >> gitRepositoryACommitNewAddedPage [
	<gtExample>
	<after: #cleanUpRepositoriesAndDatabases>
	| gtIceRepository |
	gtIceRepository := self gitRepositoryAWithNewAddedPage.
	
	gtIceRepository executeCommit: 'Add Page1'.
	
	self assert: gtIceRepository getDeltasForFullDiff isEmpty.
	self assert: gtIceRepository workingCopyDiff isEmpty.
	
	^ gtIceRepository
]

{ #category : #'examples - checkout' }
GtIceLepiterExamples >> gitRepositoryACommitNewPageInSecondBranch [
	<gtExample>
	
	| gtIceRepository targetDatabase newPage |
	gtIceRepository := self gitRepositoryACheckoutNewBranch.
	targetDatabase := gtIceRepository lepiterWorkingCopy databases anyOne.
	
	newPage := LePage named: 'Page2'.
	newPage addSnippet: (LeTextSnippet string: 'Snippet2').
	targetDatabase addPage: newPage.
	self assertOneAddedPage: newPage inRepository: gtIceRepository.
	
	gtIceRepository executeCommit: 'Add Page2'.
	self assertNoChangesInRepository:  gtIceRepository.
	self assert: targetDatabase pageCount equals: 2.
	self assert: (targetDatabase hasPageNamed: 'Page2').
	
	^ gtIceRepository
]

{ #category : #'examples - checkout' }
GtIceLepiterExamples >> gitRepositoryACommitNewPageInSecondBranch_checkoutMainBranch [
	<gtExample>
	
	| gtIceRepository targetDatabase |
	gtIceRepository := self gitRepositoryACommitNewPageInSecondBranch.
	targetDatabase := gtIceRepository lepiterWorkingCopy databases anyOne.
	
	gtIceRepository 
		gtLepiterAwareCheckoutBranch: self mainBranchName.
	self assertNoChangesInRepository:  gtIceRepository.
	
	self assert: targetDatabase pageCount equals: 1.
	self assert: (targetDatabase hasPageNamed: 'Page1').
	self assert: (targetDatabase hasPageNamed: 'Page2') not.
	
	^ gtIceRepository
]

{ #category : #'examples - merge' }
GtIceLepiterExamples >> gitRepositoryACommitNewPageInSecondBranch_checkoutMainBranch_mergeSecondBranch [
	<gtExample>
	
	| gtIceRepository targetDatabase |
	gtIceRepository := self gitRepositoryACommitNewPageInSecondBranch_checkoutMainBranch.
	targetDatabase := gtIceRepository lepiterWorkingCopy databases anyOne.
	
	gtIceRepository lepiterWorkingCopy 
		mergeCommit: (gtIceRepository icebergRepository 
			branchNamed: self secondaryBranchName) commit.
	self assertNoChangesInRepository:  gtIceRepository.
	
	self assert: targetDatabase pageCount equals: 2.
	self assert: (targetDatabase hasPageNamed: 'Page1').
	self assert: (targetDatabase hasPageNamed: 'Page2').
	
	^ gtIceRepository
]

{ #category : #'examples - single page' }
GtIceLepiterExamples >> gitRepositoryACommitNewUnnamedAddedPage [
	<gtExample>
	<after: #cleanUpRepositoriesAndDatabases>
	| gtIceRepository |
	gtIceRepository := self gitRepositoryAWithNewUnnamedAddedPage.
	
	gtIceRepository executeCommit: 'Add Page1 unnamed'.
	
	self assert: gtIceRepository getDeltasForFullDiff isEmpty.
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
	
	self assert: gtIceRepository getDeltasForFullDiff isEmpty.
	self assert: gtIceRepository workingCopyDiff isEmpty.
	
	^ gtIceRepository
]

{ #category : #'examples - checkout' }
GtIceLepiterExamples >> gitRepositoryACommitRemovedPageInSecondBranch [
	<gtExample>
	
	| gtIceRepository targetDatabase existingPage |
	gtIceRepository := self gitRepositoryACheckoutNewBranch.
	targetDatabase := gtIceRepository lepiterWorkingCopy databases anyOne.
	
	existingPage := targetDatabase pageNamed: 'Page1'.
	existingPage removeSelf.
	self 
		assertOneRemovedPage: existingPage 
		fromDatabase: targetDatabase 
		inRepository: gtIceRepository.
	
	gtIceRepository executeCommit: 'Remove Page1'.
	self assertNoChangesInRepository:  gtIceRepository.
	self assert: targetDatabase pageCount equals: 0.
	self assert: (targetDatabase hasPageNamed: 'Page1') not.
	
	^ gtIceRepository
]

{ #category : #'examples - checkout' }
GtIceLepiterExamples >> gitRepositoryACommitRemovedPageInSecondBranch_checkoutMainBranch [
	<gtExample>
	
	| gtIceRepository targetDatabase |
	gtIceRepository := self gitRepositoryACommitRemovedPageInSecondBranch.
	targetDatabase := gtIceRepository lepiterWorkingCopy databases anyOne.
	
	gtIceRepository 
		gtLepiterAwareCheckoutBranch: self mainBranchName.
	self assertNoChangesInRepository:  gtIceRepository.
	
	self assert: targetDatabase pageCount equals: 1.
	self assert: (targetDatabase hasPageNamed: 'Page1').
	
	^ gtIceRepository
]

{ #category : #'examples - merge' }
GtIceLepiterExamples >> gitRepositoryACommitRemovedPageInSecondBranch_checkoutMainBranch_mergeSecondBranch [
	<gtExample>
	
	| gtIceRepository targetDatabase |
	gtIceRepository := self gitRepositoryACommitRemovedPageInSecondBranch_checkoutMainBranch.
	targetDatabase := gtIceRepository lepiterWorkingCopy databases anyOne.
	
	gtIceRepository lepiterWorkingCopy 
		mergeCommit: (gtIceRepository icebergRepository 
			branchNamed: self secondaryBranchName) commit.
	self assertNoChangesInRepository:  gtIceRepository.
	
	self assert: targetDatabase pageCount equals: 0.
	self assert: (targetDatabase hasPageNamed: 'Page1') not.
	
	^ gtIceRepository
]

{ #category : #'examples - pages' }
GtIceLepiterExamples >> gitRepositoryACommitTwoNewUnnamedAddedPage [
	<gtExample>
	<after: #cleanUpRepositoriesAndDatabases>
	| gtIceRepository |
	gtIceRepository := self gitRepositoryAWithTwoNewUnnamedAddedPage.
	
	gtIceRepository executeCommit: 'Add Two Pages'.
	
	self assert: gtIceRepository getDeltasForFullDiff isEmpty.
	self assert: gtIceRepository workingCopyDiff isEmpty.
	
	^ gtIceRepository
]

{ #category : #'examples - single page' }
GtIceLepiterExamples >> gitRepositoryAEditExistingPage [
	<gtExample>
	<after: #cleanUpRepositoriesAndDatabases>
	| gtIceRepository targetDatabase targetPage |
	gtIceRepository := self gitRepositoryACommitNewAddedPage.
	targetDatabase := gtIceRepository lepiterWorkingCopy databases anyOne.
	
	targetPage := targetDatabase pageNamed: 'Page1'.
	targetPage children first updateString: 'Updated Snippet1 Text'.

	self assertOneModifiedPage: targetPage inRepository: gtIceRepository.
	
	^ gtIceRepository
]

{ #category : #'examples - merge' }
GtIceLepiterExamples >> gitRepositoryAPageEditWithMergeConflict_acceptExistingChange [
	<gtExample>
	
	| mergeAction conflict |
	mergeAction := self gitRepositoryACommitEditedPageInSecondBranch_checkoutMainBranch_commitInMainBranch_mergeSecondBranchWithConflict.

	conflict := mergeAction gtConflicts first.
	conflict selectRight.
	self assert: conflict isResolved.
	
	^ mergeAction
]

{ #category : #'examples - merge' }
GtIceLepiterExamples >> gitRepositoryAPageEditWithMergeConflict_acceptExistingChange_performMerge [
	<gtExample>
	
	| mergeAction targetDatabase targetPage |
	mergeAction := self gitRepositoryAPageEditWithMergeConflict_acceptExistingChange.
	
	targetDatabase := mergeAction lepiterWorkingCopy databases anyOne.
	targetPage := targetDatabase pageNamed: 'Page1'.

	mergeAction executeWithoutConflictSignal.
	self assert: targetPage children size equals: 2.
	self assert: targetPage children second string equals: 'Snippet2-MainModified'.
	
	^ mergeAction
]

{ #category : #'examples - merge' }
GtIceLepiterExamples >> gitRepositoryAPageEditWithMergeConflict_acceptIncomingChange [
	<gtExample>
	
	| mergeAction conflict |
	mergeAction := self gitRepositoryACommitEditedPageInSecondBranch_checkoutMainBranch_commitInMainBranch_mergeSecondBranchWithConflict.

	conflict := mergeAction gtConflicts first.
	conflict selectLeft.
	self assert: conflict isResolved.
	
	^ mergeAction
]

{ #category : #'examples - merge' }
GtIceLepiterExamples >> gitRepositoryAPageEditWithMergeConflict_acceptIncomingChange_performMerge [
	<gtExample>
	
	| mergeAction targetDatabase targetPage |
	mergeAction := self gitRepositoryAPageEditWithMergeConflict_acceptIncomingChange.
	
	targetDatabase := mergeAction lepiterWorkingCopy databases anyOne.
	targetPage := targetDatabase pageNamed: 'Page1'.
	
	mergeAction executeWithoutConflictSignal.
	self assert: targetPage children size equals: 2.
	self assert: targetPage children second string equals: 'Snippet2-SecondModified'.
	
	^ mergeAction
]

{ #category : #'examples - single page' }
GtIceLepiterExamples >> gitRepositoryARemoveExistingPage [
	<gtExample>
	<after: #cleanUpRepositoriesAndDatabases>
	| gtIceRepository targetDatabase targetPage |
	gtIceRepository := self gitRepositoryACommitNewAddedPage.
	targetDatabase := gtIceRepository lepiterWorkingCopy databases anyOne.
	
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
	gtIceRepository executeCommit: 'Add Database'.
	
	self assert: gtIceRepository getDeltasForFullDiff isEmpty.
	self assert: gtIceRepository workingCopyDiff isEmpty.
	
	^ gtIceRepository
]

{ #category : #'examples - nested folder' }
GtIceLepiterExamples >> gitRepositoryAWithEmptyCommitedLepiterDatabaseInNestedFolder [
	<gtExample>
	| gtIceRepository |
	
	gtIceRepository := self gitRepositoryAWithNewEmptyNotCommitedLepiterDatabaseInNestedFolder. 
	gtIceRepository executeCommit: 'Add Nested Database'.
	
	self assert: gtIceRepository getDeltasForFullDiff isEmpty.
	self assert: gtIceRepository workingCopyDiff isEmpty.
	
	^ gtIceRepository
]

{ #category : #'examples - single page' }
GtIceLepiterExamples >> gitRepositoryAWithNewAddedPage [
	<gtExample>
	<after: #cleanUpRepositoriesAndDatabases>
	| gtIceRepository targetDatabase newPage |
	gtIceRepository := self gitRepositoryAWithEmptyCommitedLepiterDatabase.
	targetDatabase := gtIceRepository lepiterWorkingCopy databases anyOne.
	
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
		createIcebergRepositoryNamed: self repositoryName 
		withLepiterDatabaseNamed: 'database-a'. 
	
	lepiterWorkingCopy := gtIceRepository lepiterWorkingCopy.
	self assert: lepiterWorkingCopy databases size equals: 1.
	targetDatabase := lepiterWorkingCopy databases anyOne.
	self 
		assert: lepiterWorkingCopy databases anyOne databaseName 
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

{ #category : #'examples - nested folder' }
GtIceLepiterExamples >> gitRepositoryAWithNewEmptyNotCommitedLepiterDatabaseInNestedFolder [
	<gtExample>
	<after: #cleanUpRepositoriesAndDatabases>
	| gtIceRepository lepiterWorkingCopy targetDatabase diff folderOneNode folderTwoNode databaseNode |
	
	gtIceRepository := self 
		createIcebergRepositoryNamed: self repositoryName 
		withLepiterDatabaseNamed: 'database-a'
		atLocation: 'lepiter/foo/bar'.
	
	lepiterWorkingCopy := gtIceRepository lepiterWorkingCopy.
	self assert: lepiterWorkingCopy databases size equals: 1.
	targetDatabase := lepiterWorkingCopy databases anyOne.
	self 
		assert: lepiterWorkingCopy databases anyOne databaseName 
		equals: 'database-a'.
	
	diff := lepiterWorkingCopy diffToReferenceCommit.
	self assert: diff isEmpty not.

	self assertDiff: diff withChildrenCount: 1 andFullCount: 5.
	
	folderOneNode := diff tree children first.
	self 
		assertFolderNode: folderOneNode
		forName: 'lepiter'
		withChildrenCount: 1.
	
	folderTwoNode := folderOneNode children first.
	self 
		assertFolderNode: folderTwoNode
		forName: 'foo'
		withChildrenCount: 1.
		
	databaseNode := folderTwoNode children first.
	self
		assertDatabaseNode: databaseNode
		forDatabase: targetDatabase
		withChildrenCount: 1.
	self
		assertDatabasePropertiesNode: databaseNode children first
		forDatabase: targetDatabase
		withOperation: #add.
	self assert: databaseNode value definition localRootRelativePath equals: (Path * 'lepiter' / 'foo' / 'bar').
	
	^ gtIceRepository
]

{ #category : #'examples - attachments' }
GtIceLepiterExamples >> gitRepositoryAWithNewPageWithAttachment [
	<gtExample>
	<after: #cleanUpRepositoriesAndDatabases>
	| gtIceRepository targetDatabase newPage diff databaseNode pagesNode attachmentsNode |
	gtIceRepository := self gitRepositoryAWithEmptyCommitedLepiterDatabase.
	targetDatabase := gtIceRepository lepiterWorkingCopy databases anyOne.
	
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
	targetDatabase := gtIceRepository lepiterWorkingCopy databases anyOne.
	
	newPage := LePage unnamedPage.
	newPage addSnippet: (LeTextSnippet string: 'Block1 in Unnamed Page').
	targetDatabase addPage: newPage.
	
	deltas := gtIceRepository repository getDeltasForFullDiff.
	self assert: deltas size equals: 1.
	
	self assertOneAddedPage: newPage inRepository: gtIceRepository.
	
	^ gtIceRepository
]

{ #category : #'examples - checkout' }
GtIceLepiterExamples >> gitRepositoryAWithNoLepiterDatabase [
	<gtExample>
	<after: #cleanUpRepositoriesAndDatabases>
	
	| iceRepository gtIceRepository lepiterWorkingCopy |
	iceRepository := self createBasicIcebergRepositoryWithName: self repositoryName.
	gtIceRepository := GtGitRepository fromIcebergRepository: iceRepository.
	
	lepiterWorkingCopy := gtIceRepository lepiterWorkingCopy.
	self assert: lepiterWorkingCopy databases size equals: 0.
	self assertNoChangesInRepository: gtIceRepository.
	
	^ gtIceRepository
]

{ #category : #'examples - checkout' }
GtIceLepiterExamples >> gitRepositoryAWithNoLepiterDatabase_checkoutSecondBranch [
	<gtExample>
	
	| gtIceRepository lepiterWorkingCopy |
	gtIceRepository := self gitRepositoryAWithNoLepiterDatabase.
	
	lepiterWorkingCopy := gtIceRepository lepiterWorkingCopy.
	self assert: lepiterWorkingCopy databases size equals: 0.
	
	gtIceRepository 
		gtLepiterAwareCheckoutBranch: self secondaryBranchName.
	
	self assert: lepiterWorkingCopy databases size equals: 0.
	self assertNoChangesInRepository: gtIceRepository.
	
	^ gtIceRepository
]

{ #category : #'examples - checkout' }
GtIceLepiterExamples >> gitRepositoryAWithNoLepiterDatabase_checkoutSecondBranch_commitDatabase [
	<gtExample>
	
	| gtIceRepository targetDatabase lepiterWorkingCopy newPage |
	gtIceRepository := self gitRepositoryAWithNoLepiterDatabase_checkoutSecondBranch.
	
	targetDatabase := self 
		createDatabaseNamed: 'database-a' 
		inIcebergRepository: gtIceRepository icebergRepository.
		
	"There should be deltas because the database files were written to disk"
	self assert: gtIceRepository getDeltasForFullDiff isNotEmpty.
	"The diff with the working copy is empty as the database is not yet added to the repository"
	self assert: gtIceRepository workingCopyDiff isEmpty.
		
	lepiterWorkingCopy := gtIceRepository lepiterWorkingCopy.
	lepiterWorkingCopy addDatabase: targetDatabase.
		
	gtIceRepository executeCommit: 'Add Database'.
	
	newPage := LePage named: 'Page1'.
	newPage addSnippet: (LeTextSnippet string: 'Snippet1').
	targetDatabase addPage: newPage.
	self 
		assertOneAddedPage: newPage 
		inRepository: gtIceRepository.
	
	gtIceRepository executeCommit: 'Add Page1'.
	self assertNoChangesInRepository:  gtIceRepository.
	self assert: targetDatabase pageCount equals: 1.
	self assert: newPage children size equals: 1.
	
	^ gtIceRepository
]

{ #category : #'examples - checkout' }
GtIceLepiterExamples >> gitRepositoryAWithNoLepiterDatabase_checkoutSecondBranch_commitDatabase_checkoutMainBranch [
	"Example for checking out a branch that removes a database. The current branch has a Lepiter databases.
	The main branch does not have the database. Switching to the main branch should remove the database."
	<gtExample>
	
	| gtIceRepository lepiterWorkingCopy |
	gtIceRepository := self gitRepositoryAWithNoLepiterDatabase_checkoutSecondBranch_commitDatabase.
	
	gtIceRepository 
		gtLepiterAwareCheckoutBranch: self mainBranchName.
		
	lepiterWorkingCopy := gtIceRepository lepiterWorkingCopy.
	self assertNoChangesInRepository:  gtIceRepository.
	self assert: (self databaseLocationForRepository: gtIceRepository icebergRepository) files size equals: 0.
	
	self assert: lepiterWorkingCopy databases size equals: 0.
	
	^ gtIceRepository
]

{ #category : #'examples - merge' }
GtIceLepiterExamples >> gitRepositoryAWithNoLepiterDatabase_checkoutSecondBranch_commitDatabase_checkoutMainBranch_mergeSecondBranch [
	"Example for merging a branch that has a lepiter database"
	<gtExample>
	
	| gtIceRepository lepiterWorkingCopy targetDatabase |
	gtIceRepository := self gitRepositoryAWithNoLepiterDatabase_checkoutSecondBranch_commitDatabase_checkoutMainBranch.
	lepiterWorkingCopy := gtIceRepository lepiterWorkingCopy.
	
	lepiterWorkingCopy 
		mergeCommit: (gtIceRepository icebergRepository 
			branchNamed: self secondaryBranchName) commit.
	self assertNoChangesInRepository:  gtIceRepository.
	
	"Databases are not added automatically."
	self assert: lepiterWorkingCopy databases size equals: 0.
	
	targetDatabase := self loadDatabaseInIcebergRepository: gtIceRepository icebergRepository.
	lepiterWorkingCopy addDatabase: targetDatabase.
	
	self assert: (targetDatabase hasPageNamed: 'Page1').
	
	^ gtIceRepository
]

{ #category : #'examples - pages' }
GtIceLepiterExamples >> gitRepositoryAWithTwoNewUnnamedAddedPage [
	<gtExample>
	<after: #cleanUpRepositoriesAndDatabases>
	| gtIceRepository targetDatabase newPage1 newPage2 diff databaseNode pagesNode deltas |
	gtIceRepository := self gitRepositoryAWithEmptyCommitedLepiterDatabase.
	targetDatabase := gtIceRepository lepiterWorkingCopy databases anyOne.
	
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

{ #category : #'creation repositories' }
GtIceLepiterExamples >> loadDatabaseInIcebergRepository: iceRepository [
	^ LeLocalStoreLoad current 
		loadAndMonitorFrom: (self databaseLocationForRepository: iceRepository)
		saveDelay: 0 seconds.

]

{ #category : #'accessing - names' }
GtIceLepiterExamples >> mainBranchName [
	^ 'master'
]

{ #category : #'accessing - names' }
GtIceLepiterExamples >> mainBranchNames [
	^ {'master'.
		'main'}
]

{ #category : #'creation repositories' }
GtIceLepiterExamples >> randomTempFolderFor: repositoryName [
	^ FileReference newTempFilePrefix: repositoryName suffix: 'dir'
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

{ #category : #'accessing - names' }
GtIceLepiterExamples >> repositoryName [
	^ 'repo-a'
]

{ #category : #'accessing - names' }
GtIceLepiterExamples >> secondaryBranchName [
	^ 'second'
]
