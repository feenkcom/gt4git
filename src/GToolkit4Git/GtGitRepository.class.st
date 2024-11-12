"
{{gtClass:GtGitRepository}} augments an Iceberg repository with a gt-specific working copy that can handle Lepiter databases and other files. 
It also relies on a gt-specific working copy ({{gtClass:GtLepiterWorkingCopy}}) for peforming operations that afect the state of the image.
"
Class {
	#name : #GtGitRepository,
	#superclass : #Object,
	#traits : 'TGtAnnouncer',
	#classTraits : 'TGtAnnouncer classTrait',
	#instVars : [
		'icebergRepository',
		'announcer',
		'lepiterWorkingCopy',
		'status',
		'viewModel'
	],
	#category : #'GToolkit4Git-Model'
}

{ #category : #'instance creation' }
GtGitRepository class >> forClass: aClass [
	^ self forPackage: aClass package
]

{ #category : #'instance creation' }
GtGitRepository class >> forPackage: aPackage [
	| repository |
	repository := IceRepository registry
			detect: [ :aRepo | 
				aRepo workingCopy loadedPackages
					anySatisfy: [ :icePackage | icePackage package sameContentAs: aPackage name ] ]
			ifNone: [ nil ].
	^ repository ifNotNil: [ self fromIcebergRepository: repository ]
]

{ #category : #'instance creation' }
GtGitRepository class >> forRepoNamed: repoName [
	"GtGitRepository forRepoNamed: 'gtoolkit'"

	| repo |
	repo := IceRepository registry detect: [ :aRepo | aRepo name = repoName ].
	^ GtGitRepository fromIcebergRepository: repo
]

{ #category : #'instance creation' }
GtGitRepository class >> fromIcebergRepository: anIceRepository [
	^ self new 
		icebergRepository: anIceRepository
]

{ #category : #'api - actions adding/removing' }
GtGitRepository >> addBaseline: aBaselineName [

	self addBaseline: aBaselineName withPackages: {}
]

{ #category : #'api - actions adding/removing' }
GtGitRepository >> addBaseline: aBaselineName withPackages: aListOfPackages [
	(RBAddPackageChange addPackageNamed: aBaselineName) execute.
	(RBAddClassChange
		definition: 'BaselineOf subclass: #' , aBaselineName
				, '
	instanceVariableNames: ''''
	classVariableNames: ''''
	poolDictionaries: ''''
	package: ''' , aBaselineName , '''') execute.
	(RBAddMethodChange
		compile: 'baseline: spec
	<baseline>
		^ spec for: #common do: [
			'
				, ('.
			'
						join: (aListOfPackages
								collect: [ :aPackage | 'spec package: ''' , aPackage name , '''' ]))
				, '
		]'
		in: aBaselineName asClass
		classified: #baseline) execute.

	self icebergWorkingCopy addPackageNamed: aBaselineName.
	self announceRepositoryModified
]

{ #category : #'api - actions adding/removing' }
GtGitRepository >> addBaselineWithAllPackages: aBaselineName [
	self addBaseline: aBaselineName withPackages: self workingCopy packages
]

{ #category : #'api - actions adding/removing' }
GtGitRepository >> addNewDatabaseInDirectory: aDirectory [

	self lepiterWorkingCopy addNewDatabaseInDirectory: aDirectory.
	self announceRepositoryModified.
]

{ #category : #'api - actions adding/removing' }
GtGitRepository >> addPackage: aPackageName [
	"Add a package with a given name to the git repository.
	Creates a package if it doesn't exist in the image"

	(RPackageOrganizer default includesPackageNamed: aPackageName)
		ifFalse: [ (RBAddPackageChange addPackageNamed: aPackageName) execute ].

	self icebergWorkingCopy addPackageNamed: aPackageName.
	self announceRepositoryModified.

	^ aPackageName asPackage
]

{ #category : #accessing }
GtGitRepository >> allCommits [
	^self repository allCommits
]

{ #category : #announcer }
GtGitRepository >> announceRepositoryModified [
	Iceberg announcer announce:
		(IceRepositoryModified for: self icebergRepository)
]

{ #category : #announcer }
GtGitRepository >> announcer [
	<return: #Announcer>
	^ announcer
]

{ #category : #accessing }
GtGitRepository >> baselines [
	^ ((self icebergWorkingCopy loadedPackages 
		select: [ :aPackage | aPackage isMetacelloBaseline ]) 
		collect: [ :aPackage | aPackage name ]) asOrderedCollection
]

{ #category : #magritte }
GtGitRepository >> baselinesDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		label: 'Baselines';
		priority: 6;
		labelAptitude: [ BrGlamorousLabelAptitude new glamorousFormLabelStyle ];
		accessor: (MAPluggableAccessor
				read: #baselines
				write: [ :aModel :aValue | 
					aModel baselines
						removeAllFoundIn: aValue;
						do: [ :baseline | self removeBaseline: baseline ].
					aValue
						removeAllFoundIn: aModel baselines;
						collect: [ :baseline | self addBaseline: baseline ] ]);
		classes: {String};
		blocListStencil: [ :aMemento :aDescription :aForm | 
			| aTagger |
			aTagger := BrTagger new.
			aTagger
				margin: ((BlInsets left: 7) withBottom: 4);
				hMatchParent;
				vFitContent.
			aForm hMatchParent.
			aTagger
				aptitude: (GtCreationEditableTaggerAptitude new
						margin: (BlInsets right: 5);
						tagLabel: [ :aTag | 
							| aLabel |
							aLabel := BrEditableLabel new
									text: aTag name;
									aptitude: BrGlamorousEditableLabelAptitude new glamorousFormEditorCodeFontAndSize.

							(GtCompletionController
								on: aLabel
								strategy: GtBaselinesCompletionStrategy new) install.

							aLabel
								whenKey: BlKeyCombination primaryB
								labelDo: [ :aShortcutEvent :aShortcut | 
									aTagger phlow
										spawnTool: (GtMethodCoderTool compiledMethod: (aTag name asClass methodDict at: #baseline:)) ].

							aLabel ]).
			aTagger
				when: BrTaggerAddTagRequest
				do: [ :aRequest | 
					| aValue |
					aValue := (aTagger tags collect: #name)
								add: aRequest tag name;
								yourself.
					
					GtMagritteBuilderUtility
						write: aValue 
						using: aDescription 
						memento: aMemento 
						element: aTagger ].
			aTagger
				when: BrTaggerRemoveTagRequest
				do: [ :aRequest | 
					| aValue |
					aValue := (aTagger tags collect: #name)
								remove: aRequest tag name;
								yourself.
					
					GtMagritteBuilderUtility
						write: aValue 
						using: aDescription 
						memento: aMemento 
						element: aTagger ].
			aTagger
				withAsyncSinkDo: [ :anElementSink | 
					anElementSink
						sink: AsyncPeekSink new;
						whenUpdate: [ :theTagger :aSink | 
							| theValues theTexts |
							theValues := aSink value currentValue.
							theTexts := theValues
									collect: [ :each | aDescription displayStringFor: each ].
							theTagger namedTags: theTexts ].
					(aMemento readObservableValueUsing: aDescription) observe: anElementSink ] ]
]

{ #category : #magritte }
GtGitRepository >> branchDescription [
	<magritteDescription>
	^ MAStringDescription new
		label: 'Branch';
		priority: 1;
		accessor: (MAPluggableAccessor
				read: [ :aModel | aModel repository branchName ]
				write: [ :aModel :aValue | aModel repository checkoutBranch: aValue ]);
		blocCompletion: [ GtStringsCompletionStrategy new
				completions: (GtPrefixTree withAll: (icebergRepository allBranches collect: #name)) ];
		editorAptitude: [ BrGlamorousRegularEditorAptitude new glamorousFormEditorCodeFontAndSize ];
		labelAptitude: [ BrGlamorousLabelAptitude new glamorousFormLabelStyle ];
		addCondition: [ :aValue | (aValue includesSubstring: '..') not ]
			labelled: 'May not contain ".."';
		addCondition: [ :aValue | (aValue includesAny: '~^:?*[\') not ]
			labelled: 'May not contain any of "~^:?*[\"';
		addCondition: [ :aValue | (aValue endsWith: '.') not ]
			labelled: 'May not end with a dot';
		addCondition: [ :aValue | ((aValue beginsWith: '/') or: [ aValue endsWith: '/' ]) not ]
			labelled: 'May not start or end with a slash';
		addCondition: [ :aValue | (aValue includesSubstring: '@{') not ]
			labelled: 'May not contain the sequence "@{"';
		addCondition: [ :aValue | (aValue = '@') not ]
			labelled: 'May not just be an "@" charater';
		addCondition: [ :aValue | (aValue includesSubstring: '//') not ]
			labelled: 'May not contain multiple consecutive slashes';
		comment: 'A branch name. If you set it to a non-existant branch, a new one will be created.'
]

{ #category : #'api - repository' }
GtGitRepository >> changes [
	^ self isModified
		ifTrue: [ self icebergWorkingCopy diffToReferenceCommit treeToShow children ]
		ifFalse: [ Array empty ]
]

{ #category : #magritte }
GtGitRepository >> codeDirectoryDescription [
	<magritteDescription>
	^ MADirectoryDescription new
		label: 'Code Directory';
		priority: 4;
		labelAptitude: [ BrGlamorousLabelAptitude new glamorousFormLabelStyle ];
		editorAptitude: [ BrGlamorousLabelAptitude new glamorousFormEditorCodeFontAndSize ];
		kind: AbstractFileReference;
		display: #pathString;
		accessor: (MAPluggableAccessor
				read: [ :aModel | aModel repository codeDirectory asFileReference ]
				write: [ :aModel :aValue | 
					icebergRepository
						codeDirectory: (aValue relativeTo: icebergRepository repositoryDirectory) pathString ])
]

{ #category : #accessing }
GtGitRepository >> conflictingCommits [

	| index commits currentIncomingCommits |
	currentIncomingCommits := self incomingCommits.
	currentIncomingCommits ifEmpty: [ ^ OrderedCollection new ].
	index := 1.
	
	commits := OrderedCollection new.
	[ 
	 index <= currentIncomingCommits size 
	 	and: [ (IceMerge new
			 repository: self icebergRepository;
		 	mergeCommit: (currentIncomingCommits at: index)) hasConflicts ]
	] whileTrue: [ 
		commits add: (currentIncomingCommits at: index).
		index := index + 1 ].
	^ commits
]

{ #category : #'gt - extensions' }
GtGitRepository >> contextMenuOptionsFor: anIceNode [
	| options |
	
	options := { } asOrderedCollection.
	(anIceNode value definition isKindOf: IceCodeDefinition) ifTrue: [
		options add: ('Revert changes' -> [ :e | 
	            self icebergWorkingCopy diffToReferenceCommit revertChanges:
		            anIceNode ]) ].
	anIceNode value canBeBrowsed ifTrue: [ 
		options addFirst: 'Browse' -> [ :e | 
			e phlow spawnTool: (anIceNode value definition toolIn: self) ] ].
	^ options
]

{ #category : #'gt - extensions' }
GtGitRepository >> createPullRequest [
	| login switcher repository upstreamOwner branchName description |
	self 
		assert: GhTokenHolder hasToken 
		description: 'Please set your GitHub Personal Access Token in GhTokenHolder'.

	login := GtGitHubAPITool new user login.

	switcher := GtIceRepositorySwitcher new
		sshUrl: self repository originUrl;
		yourself.

	repository := GtGitHubAPITool new
		repositoryOwner: switcher owner name: switcher projectName.

	(self repository isDirty or: [ self repository hasOutgoingCommits ])
		ifTrue: [ ^ self error: 'Repository is dirty, please commit and push' ].

	repository fork 
		ifFalse: [ ^ self error: 'This repository is not a fork, please fork' ].

	upstreamOwner := repository parent owner login.

	branchName := self repository branch name.
	branchName = 'main'
		ifTrue: [ ^ self error: 'Repository should be on a feature branch, please create a feature branch' ].
		
	description := self repository branch commits first comment.

	^ GtGitHubAPITool new 
		createPullRequestBy: login 
			forRepositoryOwner: upstreamOwner
			name: switcher projectName 
			branch: branchName 
			description: description
]

{ #category : #accessing }
GtGitRepository >> databases [
	^ self lepiterWorkingCopy databases
]

{ #category : #magritte }
GtGitRepository >> databasesDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		label: 'Databases';
		priority: 5;
		labelAptitude: [ BrGlamorousLabelAptitude new glamorousFormLabelStyle ];
		classes: {LeDatabase.
				FileLocator};
		accessor: (MAPluggableAccessor
				read: [ :aModel | aModel databases asOrderedCollection ]
				write: [ :aModel :aValue | 
					aModel databases asOrderedCollection
						removeAllFoundIn: aValue;
						do: [ :database | self lepiterWorkingCopy unloadDatabase: database ].
					aValue
						removeAllFoundIn: aModel databases;
						collect: [ :database | self addNewDatabaseInDirectory: database ] ]);
		blocListStencil: [ :aMemento :aDescription :aForm | 
			| aTagger |
			aTagger := BrTagger new.
			aTagger
				margin: (BlInsets left: 7);
				hMatchParent;
				vFitContent.
			aForm hMatchParent.
			aTagger
				aptitude: (BrGlamorousTaggerEditableDropdownAptitude new
						margin: (BlInsets right: 5);
						tagLabel: [ :aTag | 
							BrEditableLabel new
								text: (aDescription displayStringFor: aTag name);
								aptitude: BrGlamorousEditableLabelAptitude new glamorousFormEditorCodeFontAndSize;
								whenKey: BlKeyCombination primaryB
									labelDo: [ :aShortcutEvent :aShortcut | aTagger phlow spawnObject: aTag name ] ];
						content: [ :aDropdown :_ | 
							BrFileSelector new
								vExact: 250;
								hExact: 400;
								folder: self repository repositoryDirectory;
								addAptitude: BrGlamorousWithVerticalResizerAptitude
										+ BrGlamorousWithHorizontalResizerAptitude
										+ BrGlamorousWithHorizontalResizerAptitude new beLeft;
								fileFilterBlock: [ :aFile | aFile isDirectory ];
								okAction: [ :aDirectory :aButton | 
									aDirectory isDirectory
										ifTrue: [ 
											| aValue |
											aDropdown fireEvent: BrDropdownHideWish new.
											
											aValue := (aTagger tags collect: #name)
																		add: aDirectory;
																		yourself.
										
											GtMagritteBuilderUtility
												write: aValue 
												using: aDescription 
												memento: aMemento 
												element: aTagger.
											
											aDropdown phlow fireToolUpdateWish ] ];
								buttonLabel: 'Add database';
								padding: (BlInsets all: 10) ]).
			aTagger
				when: BrTaggerAddTagRequest
				do: [ :aRequest | 
					| aValue |
					aValue := (aTagger tags collect: #name)
									add: aRequest tag name;
									yourself.
					
					GtMagritteBuilderUtility
						write: aValue 
						using: aDescription 
						memento: aMemento 
						element: aTagger ].
			aTagger
				when: BrTaggerRemoveTagRequest
				do: [ :aRequest | 
					| aValue |
					aValue := (aTagger tags collect: #name)
								remove: aRequest tag name;
								yourself.
					
					GtMagritteBuilderUtility
						write: aValue 
						using: aDescription 
						memento: aMemento 
						element: aTagger ].
			aTagger
				withAsyncSinkDo: [ :anElementSink | 
					anElementSink
						sink: AsyncPeekSink new;
						whenUpdate: [ :theTagger :aSink | 
							| theValues |
							theValues := aSink value currentValue.
							theTagger namedTags: theValues ].
					(aMemento readObservableValueUsing: aDescription) observe: anElementSink ] ]
]

{ #category : #'api - actions' }
GtGitRepository >> executeCommit: aCommitMessage [
	| workingCopyDiff |
	
	workingCopyDiff := self workingCopyDiff.
	self icebergWorkingCopy
		commitChanges: workingCopyDiff
		withMessage: aCommitMessage
		force: false.
	
	self announceRepositoryModified.
]

{ #category : #'api - actions' }
GtGitRepository >> executeCommit: aCommitMessage withChanges: changes [
	| workingCopyDiff |
	
	workingCopyDiff := self workingCopyDiff.
	self icebergWorkingCopy
		commitChanges: (workingCopyDiff copyWithOnly: changes)
		withMessage: aCommitMessage
		force: false.
	
	self announceRepositoryModified.
]

{ #category : #'api - actions' }
GtGitRepository >> fetch [
	self icebergRepository fetch.
	self announceRepositoryModified.
]

{ #category : #magritte }
GtGitRepository >> fileFormatDescription [
	<magritteDescription>
	^ MASingleOptionDescription new
		label: 'File Format';
		priority: 3;
		labelAptitude: [ BrGlamorousLabelAptitude new glamorousFormLabelStyle ];
		editorAptitude: [ BrGlamorousLabelAptitude new glamorousFormEditorCodeFontAndSize ];
		display: [ :aWriter | aWriter ifNil: [ '<unspeficied>' ] ifNotNil: [ aWriter description ] ];
		accessor: (MAPluggableAccessor
				read: [ :aModel | 
					icebergRepository project isUnborn
						ifTrue: [ nil ]
						ifFalse: [ icebergRepository project repositoryProperties fileFormat ] ]
				write: [ :aModel :aValue | 
					icebergRepository project
						fileFormat: (aValue = 'Tonel'
								ifTrue: [ IceLibgitTonelWriter ]
								ifFalse: [ IceLibgitFiletreeWriter ]).
					Iceberg announcer announce: (IceRepositoryModified for: icebergRepository) ]);
		options: {IceLibgitTonelWriter.
				IceLibgitFiletreeWriter}
]

{ #category : #'api - actions' }
GtGitRepository >> forget [
	self icebergRepository forget.
	self forgetLepiterDatabases
]

{ #category : #accessing }
GtGitRepository >> forgetLepiterDatabases [
	| registry |
	registry := LeDatabasesRegistry uniqueInstance defaultLogicalDatabase.
	self databases do: [ :database | registry removeDB: database ]
]

{ #category : #'api - actions' }
GtGitRepository >> fork [
	| login switcher clone repository |
	self 
		assert: GhTokenHolder hasToken 
		description: 'Please set your GitHub Personal Access Token in GhTokenHolder'.

	login := GtGitHubAPITool new user login.
	
	switcher := GtIceRepositorySwitcher new
		sshUrl: self repository originUrl;
		yourself.
	
	repository := GtGitHubAPITool new
		repositoryOwner: switcher owner name: switcher projectName.
	
	repository fork 
		ifTrue: [ ^ self error: 'This repository is already a fork' ].

	clone := GtGitHubAPITool new 
		forkRepositoryOwner: switcher owner name: switcher projectName.

	repository := GtGitHubAPITool new
		repositoryOwner: login name: switcher projectName.

	self assert: repository fork description: 'Fork failed'.

	switcher sshUrl: (repository at: #ssh_url).

	switcher deleteDirectory.

	switcher 
		useLibgitCLI;
		cloneAndCreate;
		register.

	^ repository
]

{ #category : #'api - repository' }
GtGitRepository >> getDeltasForFullDiff [
	^ self icebergRepository getDeltasForFullDiff
]

{ #category : #'gt - extensions' }
GtGitRepository >> gtActionExtraMenuFor: anAction [
	<gtAction>
	^ anAction 
		dropdown
		tooltip: 'More repository operations';
		icon: BrGlamorousVectorIcons hamburger;
		content: [ :aButton | 
			BrGlamorousSimpleContextMenuContent new
				items: {
					('Inspect iceberg repository' -> [ :e | 
						e phlow spawnObject: self icebergRepository.
						e fireEvent: BrDropdownHideWish new ]).
					('Inspect iceberg working copy' -> [ :e | 
						e phlow spawnObject: self icebergWorkingCopy.
						e fireEvent: BrDropdownHideWish new ]).
					('Inspect lepiter working copy' -> [ :e | 
						e phlow spawnObject: self lepiterWorkingCopy.
						e fireEvent: BrDropdownHideWish new ]).
					('Fork repository' -> [ :e | 
						e phlow spawnObject: self fork.
						e fireEvent: BrDropdownHideWish new ]).
					('Create pull request' -> [ :e | 
						e phlow spawnObject: self createPullRequest.
						e fireEvent: BrDropdownHideWish new ]).
					('Recalculate dirty packages' -> [ :e | 
						self workingCopy forceCalculateDirtyPackages. 
						e fireEvent: BrDropdownHideWish new]).
					('Open pure git repository' -> [ :e | 
						e phlow spawnObject: (PureGitRepository on: self icebergRepository location).
						e fireEvent: BrDropdownHideWish new ]).
					('Logged signals' -> [ :e | 
						e phlow spawnObject: GtGitCliSignal memoryLogger.
						e fireEvent: BrDropdownHideWish new ]).
					('Grouped events' -> [ :e | 
						e phlow spawnObject:  GtGitCliSignal groupedEvents.
						e fireEvent: BrDropdownHideWish new ]).
					('Remove repository' -> [ :e | 
						self remove. 
						e fireEvent: BrDropdownHideWish new]).
					('Forget repository' -> [ :e | 
						self forget. 
						e fireEvent: BrDropdownHideWish new ])
				};
				yourself ].
]

{ #category : #'gt - extensions' }
GtGitRepository >> gtActionFetchFor: anAction [
	<gtAction>
	^ anAction button
		label: 'Fetch';
		priority: 2;
		tooltip: 'Fetch all commits and branches from all remotes';
		action: [ :aButton |
			(IceTipRepositoryModel on: self icebergRepository) fetch.
			self announceRepositoryModified.
			aButton phlow fireToolUpdateWish ]
]

{ #category : #'gt - extensions' }
GtGitRepository >> gtActionForgetFor: anAction [
	"<gtAction>"
	^ anAction button
		label: 'Forget';
		priority: 11;
		tooltip: 'Forget this repository by unregistering it from the system';
		action: [ :aButton | self forget ]
]

{ #category : #'gt - extensions' }
GtGitRepository >> gtActionPullFor: anAction [
	<gtAction>
	
	(IceTipRepositoryModel on: self icebergRepository) isDetached ifTrue: [ 
		^ anAction noAction ].
	
	^ anAction button
		  label: 'Pull';
		  priority: 3;
		  tooltip: 'Pull all commits and branches from all remotes and merge';
		  action: [ :aButton | 
			  [ self gtLepiterAwarePull ]
				  on: IceMergeResolutionRequest
				  do: [ :r | aButton phlow spawnObject: r merge ].
			  aButton phlow fireToolUpdateWish ]
]

{ #category : #'gt - extensions' }
GtGitRepository >> gtActionPushFor: anAction [
	<gtAction>
	
	(IceTipRepositoryModel on: self icebergRepository) isDetached 
		ifTrue: [ ^ anAction noAction ].
	
	^ anAction button
		label: 'Push';
		priority: 4;
		tooltip: 'Push current commits to the default push remote';
		action: [ :aButton | 
			self icebergRepository push.
			self announceRepositoryModified.
			
			aButton phlow fireToolUpdateWish ]
]

{ #category : #'gt - extensions' }
GtGitRepository >> gtActionRefreshFor: anAction [
	<gtAction>
	^ anAction button
		label: 'Refresh';
		priority: 1;
		tooltip: 'Refresh by recomputing changes in dirty packages';
		action: [ :aButton |
		
			"Aim to only recalculate the dirty flag for packages that are marked as dirty.
			We skip packages that are not marked as dirty."

			| diff dirtyPackages |
			self icebergRepository isModified ifTrue: [ 
				"If the repository is not marked as modified no action is needed here"


				"We compute the diff but only recalculate the status for dirty packages"
				diff := IceDiff new
					sourceVersion: self icebergRepository workingCopy;
					targetVersion: self icebergRepository workingCopy referenceCommit;
					buildFull.
		
				dirtyPackages := self icebergRepository loadedPackages 
					select: [ :each | each isDirty ].
				dirtyPackages do: [ :each |
					each beDirty: (diff includesPackageNamed: each name) ].
					self announceRepositoryModified. ]. 
				
			aButton phlow fireToolUpdateWish ]. 
]

{ #category : #'gt - extensions' }
GtGitRepository >> gtActionRemoveFor: anAction [
	"<gtAction>"
	^ anAction button
		label: 'Remove';
		priority: 10;
		tooltip: 'Remove this repository';
		action: [ :aButton | self remove ]
]

{ #category : #'gt - extensions' }
GtGitRepository >> gtActionRepairFor: anAction [
	<gtAction>
	| label |
	(GtGitRepairAction subclasses
		select: [ :sc | sc iceTipClass isAvailableFor: icebergRepository ]) size = 0
		ifTrue: [ ^ anAction noAction ].
	label := self isUninitialized ifTrue: [ 'Initialize' ] ifFalse: [ 'Repair' ].
	^ anAction dropdown
		label: label;
		tooltip: label , ' this repository';
		content: [ :aDropdown | 
			GtGitRepositoryRepairStencil new
				repository: icebergRepository;
				dropdown: aDropdown ]
]

{ #category : #'gt - extensions' }
GtGitRepository >> gtAllCommitsFor: aView [
	<gtView>
	<gtRepositoryView>
	self repository isGitCliRepository ifFalse: [ ^ aView empty ].
	self isMissing ifTrue: [ ^ aView empty ].
	^ aView explicit
		title: 'All Commits' translated;
		priority: 6;
		stencil: [ | list color branches commits ruler |
			branches := self repository allBranches.
			commits := self repository allCommits.
			ruler := HiRulerBuilder
					newRulerValues: commits asOrderedCollection
					linksBlock: [ :each | each ancestors ].
			color := HiWheelColorStrategy new.
			color ruler: ruler.
			list := BrColumnedList new.
			list
				rowStencil: BrGlamorousColumnedListSelectableRowElementStencilBuilder new.
			list column
				title: 'Graph';
				stencil: [ :_ :i | ruler gtElementForRow: i value withColorStrategy: color ];
				width: 100.
			list column
				title: 'Timestamp';
				cellStencil: [ BrLabel new
						aptitude: BrGlamorousLabelAptitude new;
						hFitContent;
						vFitContent ];
				dataBinder: [ :e :i | e text: (commits at: i) timeStamp asStringYMDHM ];
				width: 120.
			list column
				title: 'Refs';
				stencil: [ :_ :i | 
					| tags each |
					each := commits at: i.
					tags := (each tags collect: #name) asOrderedCollection.
					tags
						addAll: (branches select: [ :br | br commit id = each id ] thenCollect: #name).
					BrTagger new
						aptitude: (BrGlamorousTaggerAptitude new
								tagLabel: ([ :aTag | 
									BrEditor new
										beReadOnlyWithoutSelection;
										aptitude: BrGlamorousEditableLabelAptitude new glamorousCodeTinySize;
										fitContent;
										text: aTag name ] asStencilBuilder: BrTaggerTagStencilBuilder));
						namedTags: tags ];
				width: 200.
			list column
				title: 'Commit';
				cellStencil: [ BrLabel new
						aptitude: BrGlamorousLabelAptitude new;
						hFitContent;
						vFitContent ];
				dataBinder: [ :e :i | e text: (commits at: i) shortId ];
				width: 70.
			list column
				title: 'Author';
				cellStencil: [ BrLabel new
						aptitude: BrGlamorousLabelAptitude new;
						hFitContent;
						vFitContent ];
				dataBinder: [ :e :i | e text: (commits at: i) author ];
				width: 100.
			list column
				title: 'Message';
				weight: 1;
				cellStencil: [ BrLabel new
						aptitude: BrGlamorousLabelAptitude new;
						hFitContent;
						vFitContent ];
				dataBinder: [ :e :i | e text: (commits at: i) comment trimBoth firstLineWithEllipsis ].
			list
				when: BrSelectionDoubleClicked
				do: [ :anEvent | 
					anEvent selection
						ifNotEmpty: [ :theIndices | anEvent currentTarget phlow spawnObject: (commits at: theIndices first) ] ].
			list addAptitude: BrColumnedListHeaderAptitude.
			list items: (1 to: ruler numberOfRows).
			list ]
]

{ #category : #'gt - extensions' }
GtGitRepository >> gtAllLoadedExamples [
	^ self lepiterWorkingCopy gtAllLoadedExamples
]

{ #category : #'gt - extensions' }
GtGitRepository >> gtChangesFor: aView context: aContext [
	<gtView>
	<gtRepositoryView>
	
	| aViewModel changes chosen viewMap|
	chosen := Set new.
	viewMap := Dictionary new. "item -> checkbox"

	self isMissing ifTrue: [ ^ aView empty ].

	aViewModel := self viewModel.

	self lepiterWorkingCopy ifNil: [ ^ aView empty ].
	changes := self workingCopyDiff treeToShow.
	(changes isNil or: [ changes isEmpty ]) ifTrue: [ 
		self repository isModified ifTrue: [ self refreshDirtyPackages ].
		^ aView empty ].

	changes do: [ :change | 
		change value hasChanges ifTrue: [ chosen add: change ] ].

	^ aView tree
		  title: 'Changes';
		  items: [ changes children ];
		  children: #children;
		  expandUpTo: 3;
		  priority: 3;
		  stencil: [ :anIceNode | 
			  | element contextMenuOptions |
			  contextMenuOptions := self contextMenuOptionsFor: anIceNode.
			  element := BlElement new
				             layout: BlLinearLayout horizontal alignCenterLeft;
				             constraintsDo: [ :c | 
					             c horizontal matchParent.
					             c vertical fitContent ];
				             margin: (BlInsets all: 3);
				             constraintsDo: [ :c | c vertical fitContent ];
				             aptitude:
					             (BrGlamorousWithContextMenuAptitude content: [ 
							              BrGlamorousSimpleContextMenuContent new
								              items: contextMenuOptions;
								              yourself ]).
			  anIceNode value hasChanges ifTrue: [ |cb|
				  element addChild: (cb := BrCheckbox new
						   aptitude: BrGlamorousCheckboxAptitude
							   +
								   (BrGlamorousWithLabelTooltipAptitude new text:
										    'Select for Commit');
						   checked: (chosen includes: anIceNode value );
						   whenCheckedDo: [ chosen add: anIceNode value ];
						   margin: (BlInsets right: 8);
						   whenUncheckedDo: [ 
							   chosen remove: anIceNode value ifAbsent: [  ] ]).
				   viewMap at: anIceNode value put: cb].
			  element
				  addChild:
					  (anIceNode value icon asElement constraintsDo: [ :c | 
							   c linear horizontal alignCenter ]);
				  addChild: (BrLabel new
						   aptitude: BrGlamorousLabelAptitude;
						   text: anIceNode value name asString asRopedText;
						   padding: (BlInsets
								    top: 0
								    left: 6
								    bottom: 0
								    right: 3);
						   constraintsDo: [ :c | c linear horizontal alignCenter ]) ];

		  actionButtonLabel: 'Toggle All' action: [
		  	changes do: [:change | change value hasChanges ifTrue: [ 
		  		viewMap at: change value ifPresent: [:cb |
		  			cb checked: cb isChecked not ]]]];

		  actionDropdownButtonLabel: 'Commit'
		  tooltip: 'Commit changes'
		  content: [ :aDropdown :aTarget | 
			  | editor button saveAction |
			  editor := BrEditor new
				            aptitude: BrGlamorousRegularEditorAptitude;
				            text: aViewModel commitMessage;
				            hMatchParent;
				            vFitContentLimited;
				            requestFocus.
			  editor selecter
				  all;
				  select.

			  saveAction := [ 
			                aViewModel
				                executeCommit: editor editor text asString
				                withChanges: chosen.
			                button disable.
			                aDropdown enqueueTask:
				                (BlTaskAction new action: [ 
					                 aDropdown dispatchEvent:
						                 (BrDropdownHideWish new anchor: aDropdown) ]).
			                aDropdown phlow fireToolUpdateWish ].

			  editor addEditorShortcut: (BlShortcutWithAction new
					   combination: BlKeyCombination primaryS;
					   action: saveAction).

			  button := BrButton new.
			  button
				  aptitude: BrGlamorousButtonWithIconAptitude;
				  icon: BrGlamorousVectorIcons accept;
				  label: 'Commit';
				  disabled: editor text isEmpty;
				  action: saveAction.

			  editor editor inputFilter: GtGitGitHubUrlFilter new.
				  
			  editor editor
				  when: BrTextEditorModifiedEvent
				  do: [ :anEvent | button disabled: anEvent text isEmpty ].

			  BrVerticalPane new
				  hExact: 400;
				  vFitContentLimited;
				  padding: (BlInsets all: 10);
				  addChildren: { 
						  editor.
						  button } ]
]

{ #category : #'gt - extensions' }
GtGitRepository >> gtCommitButtonsFor: item withConflicts: conflicts incoming: incoming outgoing: outgoing inPane: container [
	| merge remotes |
	remotes := self repository remotes.
	(conflicts contains: [ :aCommit | aCommit = item ])
		ifTrue: [ container
				addChild: (BrButton new
						aptitude: BrGlamorousButtonWithLabelAptitude;
						label: 'Merge';
						action: [ :aButton | aButton phlow spawnObject: merge ]) ].
	(outgoing size > 0 and: [ outgoing first = item and: [ remotes isNotEmpty ] ])
		ifTrue: [ container
				addChild: (BrButton new
						aptitude: BrGlamorousButtonWithIconAndLabelAptitude;
						label: outgoing size asString;
						icon: BrGlamorousVectorIcons up;
						action: [ :aButton | 
							self push.
							aButton phlow fireToolUpdateWish ]) ].
	(incoming size > 0 and: [ incoming first = item and: [ remotes isNotEmpty ] ])
		ifTrue: [ container
				addChild: (BrButton new
						aptitude: BrGlamorousButtonWithIconAndLabelAptitude;
						label: incoming size asString;
						icon: BrGlamorousVectorIcons down;
						action: [ :aButton | 
							self gtLepiterAwarePull.
							aButton phlow fireToolUpdateWish ]) ]
]

{ #category : #'gt - extensions' }
GtGitRepository >> gtCommitsFor: aView [
	<gtView>
	<gtRepositoryView>
	| conflicts incomingCommits outgoingCommits |
	self isMissing ifTrue: [ ^ aView empty ].

	conflicts := self conflictingCommits.
	incomingCommits := self incomingCommits.
	outgoingCommits := self viewModel outgoingCommits.
	^ aView columnedList
		title: 'Commits' translated;
		priority: 5;
		items: [ (AsyncSequenceStream forCollection: incomingCommits)
				merge: self repository head commitStream ];
		column: 'Status'
			icon: [ :item | 
				((incomingCommits contains: [ :aCommit | aCommit = item ])
					ifTrue: [ (conflicts contains: [ :aCommit | aCommit = item ])
							ifTrue: [ self
									statusElementColored: GtGitStatusConflicting color
									withTooltip: 'Conflict' ]
							ifFalse: [ self
									statusElementColored: GtGitStatusIncoming color
									withTooltip: 'Incoming' ] ]
					ifFalse: [ (outgoingCommits contains: [ :aCommit | aCommit = item ])
							ifTrue: [ self statusElementColored: GtGitStatusOutgoing color withTooltip: 'Outgoing' ]
							ifFalse: [ BlElement new ] ])
					size: 12 @ 12;
					geometry: (BlRoundedRectangleGeometry cornerRadius: 6);
					margin: (BlInsets left: 15) ]
			width: 50;
		column: 'Timestamp'
			text: [ :aCommit | aCommit timeStamp asStringYMDHM ]
			width: 120;
		column: 'Commit'
			text: #shortId
			width: 70;
		column: 'Author'
			text: #author
			width: 100;
		column: 'Description' text: [ :each | each comment trimBoth firstLineWithEllipsis ];
		column: 'Actions'
			do: [ :aColumn | 
				aColumn
					cellStencil: [ BrHorizontalPane new
							vExact: 24;
							hExact: 150;
							hMatchParent ];
					dataBinder: [ :aPane :item | 
						aPane removeChildren.
						self
							gtCommitButtonsFor: item
							withConflicts: conflicts
							incoming: incomingCommits
							outgoing: outgoingCommits
							inPane: aPane ] ];
		send: [ :each | 
			GtGitCommit new
				id: each id;
				author: each author;
				datetime: each datetime;
				ancestorIds: each ancestorIds;
				comment: each comment;
				repository: each repository;
				lepiterWorkingCopy: self lepiterWorkingCopy yourself ];
		contextItemLabel: 'Revert'
			action: [ :element :item | 
				item revert.
				self rawCommit: 'Revert ' , item shortId , ' ' , item comment.
				element phlow fireToolUpdateWish ];
		contextItemLabel: 'Checkout'
			action: [ :element :item | 
				item checkout.
				self announceRepositoryModified.
				element phlow fireToolUpdateWish ]
]

{ #category : #'gt - extensions' }
GtGitRepository >> gtExamplesFor: aView [
	<gtView>
	<gtRepositoryView>
	^ aView forward
		title: 'Examples';
		priority: 20;
		object: [ GtExampleGroup
				withAll: (self gtAllLoadedExamples collect: #asCachedExampleWithResult) ];
		view: #gtExamplesFor:
]

{ #category : #'api - actions' }
GtGitRepository >> gtLepiterAwareCheckoutBranch: aBranchName [ 
	self icebergRepository 
		gtLepiterAwareCheckoutBranch: aBranchName 
		withWorkingCopy: self lepiterWorkingCopy
]

{ #category : #accessing }
GtGitRepository >> gtLepiterAwarePull [
	self icebergRepository configureUpstreamIfNecessary.
	self icebergRepository gtPullInWorkingCopy: self lepiterWorkingCopy.


	self announceRepositoryModified
]

{ #category : #'gt - extensions' }
GtGitRepository >> gtPackagesFor: aView context: aContext [
	<gtView>
	<gtRepositoryView>
	self hasWorkingCopy ifFalse: [ ^ aView empty ].
	^ self icebergWorkingCopy gtPackagesFor: aView
]

{ #category : #'gt - extensions' }
GtGitRepository >> gtReadmeFor: aView context: aContext [
	<gtView>
	<gtRepositoryView>

	| readme |

	(self hasWorkingCopy not or: [ self icebergRepository isMissing ])
		ifTrue: [ ^ aView empty ].

	readme := self repository repositoryDirectory / 'README.md'.

	^ aView explicit
		  title: 'README';
		  priority: 10;
		  stencil: [ 
			  | snippet snippetViewModel |
			  snippet := LeTextSnippet string: (readme exists
						              ifTrue: [ readme contents ]
						              ifFalse: [ '' ]).
			  snippetViewModel := snippet asSnippetViewModel.
			  snippetViewModel coderViewModel addShortcut:
					  (BrEditorShortcut lineEnding combination:
							   (LeSnippetElement keyboardShortcut: #NewLine)).
			  snippetViewModel coderViewModel addShortcut: (BlShortcutWithAction new
						   combination: BlKeyCombination primaryS;
						   action: [ :anEvent | 
							   readme writeStreamDo: [ :stream | 
									   stream truncate.
									   (ZnNewLineWriterStream on: stream) 
									   	nextPutAll: anEvent currentTarget text asString ].
							   self repository addFileToIndex: 'README.md'.
							   self announceRepositoryModified ]).
			  ((snippetViewModel snippetView needsEmbellishments: false)
				   asElement snippetViewModel: snippetViewModel) vMatchParent ];
		  actionButtonIcon: BrGlamorousVectorIcons accept
		  	tooltip: 'Save README'
		  	action: [ :aToggle :aTab | 
			  	readme writeStreamDo: [ :stream | 
				  	stream truncate.
				  	(ZnNewLineWriterStream on: stream) nextPutAll:
					  	aTab viewContentElement children first text asString ].
			  	self repository addFileToIndex: 'README.md'.
			  	self announceRepositoryModified ]
]

{ #category : #'gt - extensions' }
GtGitRepository >> gtRepositoryDirectoryFor: aView [
	<gtView>
	<gtRepositoryView>
	
	^ aView forward 
		title: 'Repository directory';
		priority: 40;
		object: [ self icebergRepository ];
		view: #gtRepositoryDirectoryFor:
]

{ #category : #'gt - extensions' }
GtGitRepository >> gtSetupHelpFor: aView [
	<gtView>
	<gtRepositoryView>
	(self isMissing or: [ self hasNonSetupCommits and: [ self isSetupDone ] ])
		ifTrue: [ ^ aView empty ].

	^ aView columnedList
		title: 'Setup';
		priority: 0;
		items: [ self setupItems ];
		column: 'Status'
			stencil: [ :item | item buildCheckbox ]
			width: 50;
		column: 'Action' stencil: [ :item | item buildContent ]
]

{ #category : #'gt - extensions' }
GtGitRepository >> gtViewDetailsIn: composite [
	<gtView>
	^ composite columnedList
		title: 'Details';
		priority: 2;
		items: [ {
			{ 'name' . self name }.
			{ 'location' . [ self repository location ] on: Error do: [ '' ] }.
			{ 'origin' . [ self repository originUrl ] on: Error do: [ '' ] }.
			{ 'branch' . [ self repository branchName ] on: Error do: [ '' ] }.
			{ 'code directory' 
				. [ self repository codeDirectory ] on: Error do: [ '' ]
				. [ self repository codeDirectory asFileReference ] on: Error do: [ '' ]}.
			{ 'implementation' 
				. self repository isGitCliRepository 
					ifTrue: [ 'Libgit-CLI' ] 
					ifFalse: [ 'Libgit2 FFI' ] }.
			{ 'iceberg repository' . self repository }.
			{ 'iceberg working copy' . self icebergWorkingCopy }.
			{ 'lepiter working copy' . self lepiterWorkingCopy }.
			{ 'missing' . self isMissing }.
			{ 'setup done' . self isSetupDone }.
			{ 'uninitialized' . self isUninitialized }.
			{ 'modified' . [ self isModified ] on: Error do: [ '' ] }.
			{ 'dirty' . [ self repository isDirty ] on: Error do: [ '' ] }.
			{ 'committable' . self isCommittable }.
			{ 'has repository' . self hasRepository }.
			{ 'has package' . self hasPackage }.
			{ 'has database' . self hasDatabase }.
			{ 'has baseline' . self hasBaseline }.
			{ 'has commits' . self hasCommits }.
			{ 'has changes' . [ self hasChanges ] on: Error do: [ '' ] }.
			{ 'status' . self status }
		} ];
		column: 'Key' text: #first;
		column: 'Value' text: #second weight: 3;
		send: #last;
		actionUpdateButton
]

{ #category : #accessing }
GtGitRepository >> hasBaseline [
	^ (self workingCopy packages detect: #isMetacelloBaseline ifNone: [ nil ])
		isNotNil
]

{ #category : #'api - testing' }
GtGitRepository >> hasChanges [
	^ self hasWorkingCopy and: [ 
		self isModified "and: [  
			self workingCopy diffToReferenceCommit treeToShow children isNotEmpty ]" ]
]

{ #category : #'api - testing' }
GtGitRepository >> hasCommits [
	^ self isMissing not and: [ self repository head commitStream hasNext wait ]
]

{ #category : #accessing }
GtGitRepository >> hasDatabase [
	^ self isMissing not and: [ self lepiterWorkingCopy hasDatabases ]
]

{ #category : #'gt - extensions' }
GtGitRepository >> hasNonSetupCommits [
	^ self hasCommits
		and: [ self repository head commits last comment = 'Initial commit'
				ifTrue: [ self repository head commits size > 1 ]
				ifFalse: [ true ] ]
]

{ #category : #accessing }
GtGitRepository >> hasPackage [
	^ self workingCopy packages size > 0
]

{ #category : #'api - testing' }
GtGitRepository >> hasRepository [
	^ self icebergRepository isNotNil
]

{ #category : #'api - testing' }
GtGitRepository >> hasWorkingCopy [
	^ self hasRepository and: [ self icebergRepository workingCopy isNotNil ]
]

{ #category : #'api - repository' }
GtGitRepository >> headDescription [
	^ self icebergRepository ifNotNil: #headDescription ifNil: [ '<missing>' ]
]

{ #category : #'api - accessing' }
GtGitRepository >> icebergRepository [
	^ icebergRepository
]

{ #category : #'api - accessing' }
GtGitRepository >> icebergRepository: anIcebergRepository [

	icebergRepository == anIcebergRepository ifTrue: [ ^ self ].

	icebergRepository := anIcebergRepository makeSafe.

	lepiterWorkingCopy := GtLepiterWorkingCopy new
		icebergRepository: anIcebergRepository;
		updateDatabases
]

{ #category : #'api - accessing' }
GtGitRepository >> icebergWorkingCopy [
	^ self icebergRepository workingCopy
]

{ #category : #'api - repository' }
GtGitRepository >> incomingCommits [

	^ self isCommittable
		  ifTrue: [ self icebergRepository incomingCommits ]
		  ifFalse: [ #() ]
]

{ #category : #initialization }
GtGitRepository >> initialize [
	super initialize.
	announcer := Announcer new
]

{ #category : #'api - testing' }
GtGitRepository >> isCommittable [

	^ self hasWorkingCopy and: [ self icebergRepository isMissing not  
		    and: [ 
			    self icebergRepository workingCopy workingCopyState
				    isUnknownCommitState not   and: [ 
		   self icebergRepository workingCopy isDetached not    and: [ 
		  self icebergRepository head isDetached not ] ] ] ]
]

{ #category : #'api - testing' }
GtGitRepository >> isMissing [
	^ self icebergRepository isMissing
]

{ #category : #'api - testing' }
GtGitRepository >> isModified [

	^ (self icebergRepository isModified or: [ 
		   self lepiterWorkingCopy hasDatabases and: [ 
			   self icebergRepository isDirty ] ]) or: [ 
		  self lepiterWorkingCopy changesToHeadUsingIndex isNotEmpty ]
]

{ #category : #'gt - extensions' }
GtGitRepository >> isSetupDone [
	^ (self setupItems
		reject: [ :aSetupItem | aSetupItem isRequired not or: [ aSetupItem isExecuted ] ])
		isEmpty
]

{ #category : #'api - testing' }
GtGitRepository >> isUninitialized [
	^ self workingCopy project isUnborn
]

{ #category : #'gt - extensions' }
GtGitRepository >> lepiterWorkingCopy [
	^ lepiterWorkingCopy
]

{ #category : #'api - accessing' }
GtGitRepository >> lepiterWorkingCopy: aLepiterWorkingCopy [
	lepiterWorkingCopy := aLepiterWorkingCopy
]

{ #category : #'api - repository' }
GtGitRepository >> name [
	^ self icebergRepository ifNotNil: #name ifNil: [ '<missing>' ]
]

{ #category : #'private - announcement handling' }
GtGitRepository >> onRepositoryModifiedAnnouncement: anAnnouncement [
	anAnnouncement repository = self icebergRepository ifTrue: [ ^ self ].
	
	self announce: anAnnouncement
]

{ #category : #magritte }
GtGitRepository >> originDescription [
	<magritteDescription>
	^ MAStringDescription new
		label: 'Origin';
		priority: 2;
		editorAptitude: [ BrGlamorousRegularEditorAptitude new glamorousFormEditorCodeFontAndSize ];
		labelAptitude: [ BrGlamorousLabelAptitude new glamorousFormLabelStyle ];
		accessor: (MAPluggableAccessor
				read: [ :aModel | aModel repository originUrl ]
				write: [ :aModel :aValue | 
					aModel repository origin isUndefined
						ifTrue: [ | remote |
							remote := IceGitRemote name: 'origin' url: aValue.
							aModel repository addRemote: remote.
							remote fetch ]
						ifFalse: [ aModel repository setOriginTo: aValue ] ])
]

{ #category : #'api - repository' }
GtGitRepository >> outgoingCommits [

	^ self isCommittable
		  ifTrue: [ self icebergRepository outgoingCommits ]
		  ifFalse: [ #(  ) ]
]

{ #category : #printing }
GtGitRepository >> printOn: aStream [
	aStream
		nextPutAll: (self icebergRepository
				ifNil: [ '<unknown>' ]
				ifNotNil: [ self icebergRepository name ])
]

{ #category : #'api - actions' }
GtGitRepository >> pull [
	self icebergRepository configureUpstreamIfNecessary.
	self icebergRepository pull.
	
	self announceRepositoryModified.
]

{ #category : #'api - actions' }
GtGitRepository >> push [
	self icebergRepository configureUpstreamIfNecessary.
	self icebergRepository push.
	
	self announceRepositoryModified.
]

{ #category : #accessing }
GtGitRepository >> rawCommit: aCommitMessage [

	self icebergRepository
		commitIndexWithMessage: aCommitMessage
		andParents: (self icebergWorkingCopy workingCopyState referenceCommits reject: [ :each | each isNoCommit ]).
	self announceRepositoryModified.
]

{ #category : #'gt - extensions' }
GtGitRepository >> refreshDirtyPackages [

	self icebergRepository workingCopy refreshDirtyPackages.
	self icebergRepository isModified ifFalse: [ 
		self announceRepositoryModified. ]
]

{ #category : #'api - actions' }
GtGitRepository >> remove [
	self icebergRepository delete.
	self forgetLepiterDatabases
]

{ #category : #'api - actions adding/removing' }
GtGitRepository >> removeBaseline: aBaseline [

	self icebergRepository workingCopy removePackageNamed: aBaseline.
	self icebergRepository workingCopy refreshPackages.
	self announceRepositoryModified.
]

{ #category : #accessing }
GtGitRepository >> repairActions [

	^ GtGitRepairAction subclasses select: [ :sc | 
		  sc iceTipClass isAvailableFor: self icebergRepository ]
]

{ #category : #accessing }
GtGitRepository >> repairStencil [

	^ GtGitRepositoryRepairStencil new repository: icebergRepository
]

{ #category : #'api - accessing' }
GtGitRepository >> repository [
	^ icebergRepository
]

{ #category : #'api - accessing' }
GtGitRepository >> repository: anIcebergRepository [
	self icebergRepository: anIcebergRepository
]

{ #category : #'gt - extensions' }
GtGitRepository >> setupDefaultSourceDirectoryAction [
	^ BrButton new
		label: 'Create default source directory';
		aptitude: BrGlamorousButtonWithLabelAptitude;
		action: [ | model |
			model := IceBasicProject onRepository: self repository.
			model sourceDirectory: self repository repositoryDirectory / 'src'.
			model fileFormat: IceLibgitTonelWriter.
			self assert: model repositoryProperties fileFormat = IceLibgitTonelWriter.
			self repository workingCopy project: model.
			Iceberg announcer announce: (IceRepositoryModified for: self repository) ]
]

{ #category : #'gt - extensions' }
GtGitRepository >> setupInstructions [
	| aStream |
	aStream := BlTextStream new.
	aStream next
		appendingAdornment: [ self disabledCheckBoxChecked: self repository project isUnborn not ];
		putAll: ' '.
	aStream next
		appendingAdornment: [ self setupDefaultDirectoryAction ];
		putAll: ' '.
	aStream next
		appendingAdornment: [ self setupSourceDirectoryAction ];
		putAll: ' or '.
	aStream next cr.

	aStream next
		appendingAdornment: [ self disabledCheckBoxChecked: self hasPackage ];
		putAll: ' '.
	aStream next
		appendingAdornment: [ self setupPackageAction ];
		putAll: ' '.
	aStream next cr.
		
	aStream next
		appendingAdornment: [ self disabledCheckBoxChecked: self hasBaseline ];
		putAll: ' '.
	aStream next
		appendingAdornment: [ self setupBaselineAction ];
		putAll: ' '.
	aStream next cr.

	aStream next
		appendingAdornment: [ self disabledCheckBoxChecked: self hasDatabase ];
		putAll: ' '.
	aStream next
		appendingAdornment: [ self setupLepiterDatabaseAction ];
		putAll: ' '.


	^ aStream contents
]

{ #category : #'gt - extensions' }
GtGitRepository >> setupItems [
	^ (GtGitRepositorySetupItem allSubclasses sorted: #priority ascending)
		collect: [ :aClass | aClass new repository: self ]
]

{ #category : #'api - actions' }
GtGitRepository >> squash [

	^ self notYetImplemented
	
	"| target message |
	target := self repository branch commits detect: [ :commit | 
		          (self outgoingCommits contains: [ :aCommit | 
			           aCommit = commit ]) not ].
			           
	message := Character cr join: (self outgoingCommits collect: #comment).

	self repository repositoryHandle
		resetTo: target libgitCommit
		resetType: LGitResetTypeEnum git_reset_soft
		checkoutOptions: LGitCheckoutOptions defaults.
		
	self rawCommit: message."
]

{ #category : #accessing }
GtGitRepository >> status [
	^ status ifNil: [ status := (IceTipRepositoryModel on: self icebergRepository) status ]
]

{ #category : #accessing }
GtGitRepository >> statusElementColored: aColor withTooltip: aString [

	^ BlElement new
		  background: aColor;
		  aptitude: (BrGlamorousWithLabelTooltipAptitude new text: aString)
]

{ #category : #accessing }
GtGitRepository >> statusModel [

	| conflicting |
	[ 
	| entity statusCollection incoming outgoing |
	entity := self icebergRepository.

	entity isMissing ifTrue: [ ^ { GtGitStatusMissing new } ].

	entity workingCopy workingCopyState isUnknownCommitState ifTrue: [ 
		^ { (GtGitStatusUnknownCommitState new message:
			   entity workingCopy workingCopyState description) } ].
	entity workingCopy isDetached ifTrue: [ 
		^ { GtGitStatusDetachedWorkingCopy new } ].
	(entity head isDetached and: [ entity head tags notEmpty ]) ifTrue: [ 
		^ { GtGitStatusDetachedHead new } ].
	entity head isDetached ifTrue: [ ^ { GtGitStatusDetachedHead new } ].

	entity workingCopy project isUnborn ifTrue: [ 
		^ { GtGitStatusNoProject new } ].

	statusCollection := OrderedCollection new.
	self isModified ifTrue: [ 
		statusCollection add: GtGitStatusUncommittedChanges new ].

	conflicting := self conflictingCommits size.
	conflicting > 0 ifTrue: [ 
		statusCollection add: (GtGitStatusConflicting new count: conflicting) ].

	incoming := self incomingCommits size - conflicting.
	incoming > 0 ifTrue: [ 
		statusCollection add: (GtGitStatusIncoming new count: incoming) ].

	outgoing := self outgoingCommits size.
	outgoing > 0 ifTrue: [ 
		statusCollection add: (GtGitStatusOutgoing new count: outgoing) ].


	^ statusCollection ]
		on: Error
		do: [ :error | 
			^ { (GtGitStatusUnknownError new message: error description) } ]
]

{ #category : #'gt - extensions' }
GtGitRepository >> viewModel [
	^ viewModel ifNil: [ viewModel := GtGitRepositoryViewModel new repositoryModel: self ]
]

{ #category : #'api - accessing' }
GtGitRepository >> workingCopy [
	"In several places this is used as a IceGitRepository.
	That is why this method returns the Iceberg working copy."
	^ self icebergWorkingCopy
]

{ #category : #'api - repository' }
GtGitRepository >> workingCopyDiff [
	^ self lepiterWorkingCopy diffToReferenceCommit
]
