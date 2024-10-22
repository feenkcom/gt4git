Extension { #name : #IceRepository }

{ #category : #'*GToolkit4Git' }
IceRepository >> configureUpstreamIfNecessary [
	self subclassResponsibility
]

{ #category : #'*GToolkit4Git' }
IceRepository class >> creatorClass [
	self subclassResponsibility
]

{ #category : #'*GToolkit4Git' }
IceRepository >> gtLepiterAwareCheckoutBranch: branchName withWorkingCopy: aLepiterWorkingCopy [
	"Convenience method to checkout all packages from a branch given a branch name"

	(self
		branchNamed: branchName
		ifAbsent: [
			self createBranch: branchName ]) gtLepiterAwareCheckoutWithWorkingCopy: aLepiterWorkingCopy
]

{ #category : #'*GToolkit4Git' }
IceRepository >> gtLocalBranchesFor: aView [
	<gtView>
	^ aView list
		title: 'Branches' translated;
		priority: 20;
		items: [ self localBranches ];
		itemText: [ :each | 
			| text |
			text := ((each isDirty ifTrue: [ '*' ] ifFalse: [ '' ]) , each name)
					asRopedText.
			each isLoaded ifTrue: [ text bold ].
			text ];
		actionStencil: [ :aTab | | aptitude |
			aptitude := BrGlamorousWithDropdownAptitude
				handle: [
					BrButton new
						aptitude: BrGlamorousButtonWithIconAptitude;
						icon: BrGlamorousVectorIcons add;
						label: 'Create new branch' ]
				content: [ | branchCreationPane |
					branchCreationPane := GtGitBranchCreationPane new.
					branchCreationPane
						acceptAction: [ :aModel :aButton | | branchName |
							branchName := branchCreationPane branchName.
							self 
								createBranch: branchName; 
								configureUpstreamIfNecessary.
							aButton enqueueTask: (BlTaskAction new 
								action: [ aTab viewContentElement phlow update.
									aButton fireEvent: BrDropdownHideWish new]) ];
						cancelAction: [ :aModel :aButton |
							aButton enqueueTask: (BlTaskAction new 
								action: [ aButton fireEvent: BrDropdownHideWish new ]) ].
					branchCreationPane asElement ].			
			BrButton new
				aptitude: BrGlamorousButtonWithIconAptitude + aptitude;
				icon: BrGlamorousVectorIcons add;
				label: 'Create new branch' ]
]

{ #category : #'*GToolkit4Git' }
IceRepository >> gtPackagesFor: aView [
	<gtView>
	^ self workingCopy 
		ifNil: [ aView ]
		ifNotNil: [ self workingCopy gtPackagesFor: aView ]
]

{ #category : #'*GToolkit4Git' }
IceRepository >> gtPullInWorkingCopy: aLepiterWorkingCopy [
	"A copy of the #pull method to support a Lepiter-aware pull."
	self branch gtPullInWorkingCopy: aLepiterWorkingCopy
]

{ #category : #'*GToolkit4Git' }
IceRepository >> gtRemoteBranchesFor: aView [
	<gtView>
	^ aView list
		title: 'Remote Branches' translated;
		priority: 24;
		items: [ self remoteTrackedBranches ];
		itemText: #name
]

{ #category : #'*GToolkit4Git' }
IceRepository >> gtSpotterActDefaultFrom: aSourceElement [
 	^ (GtGitElement new 
		repository: (GtGitRepository fromIcebergRepository: self);
		openInPagerFrom: aSourceElement) maximized

]

{ #category : #'*GToolkit4Git' }
IceRepository >> gtTagsFor: aView [
	<gtView>
	^ aView list
		title: 'Tags' translated;
		priority: 30;
		items: [ self tags ];
		itemText: [ :anIceTag | 
			anIceTag name , ' [' , (anIceTag commit id first: 7) , ']' ]
]

{ #category : #'*GToolkit4Git' }
IceRepository >> gtToolActionFor: composite [
	<gtAction>
	^ composite button
		label: 'Tool';
		priority: 30;
		tooltip: 'Open tool wrapper';
		action: [ :aButton | 
			aButton phlow 
				spawnObject: (GtGitRepository fromIcebergRepository: self) ]
]

{ #category : #'*GToolkit4Git' }
IceRepository >> gtViewDetailsIn: composite [
	<gtView>
	^ composite columnedList
		title: 'Details';
		priority: 5;
		items: [ {
			{ 'name' . self name }.
			{ 'origin' . [ self originUrl ] on: Error do: [ '' ] }.
			{ 'branch' . [ self branchName ] on: Error do: [ '' ] }.
			{ 'code directory' 
				. [ self codeDirectory ] on: Error do: [ '' ]
				. [ self codeDirectory asFileReference ] on: Error do: [ '' ]}.
			{ 'head' . self head }.
			{ 'head commit' . self headCommit }.
			{ 'working copy' . self workingCopy }.
			{ 'index' . self index }.
			{ 'implementation' 
				. self isGitCliRepository 
					ifTrue: [ 'Libgit-CLI' ] 
					ifFalse: [ 'Libgit2 FFI' ] }.
			{ 'missing' . self isMissing }.
			{ 'modified' . [ self isModified ] on: Error do: [ '' ] }.
			{ 'dirty' . [ self isDirty ] on: Error do: [ '' ] }.
		} ];
		column: 'Key' text: #first;
		column: 'Value' text: #second weight: 3;
		send: #last;
		actionUpdateButton
]

{ #category : #'*GToolkit4Git' }
IceRepository >> gtViewDiffToReferenceCommitFor: aView [
	"<gtView>"
	^ self workingCopy 
		ifNil: [ aView ]
		ifNotNil: [ self workingCopy gtViewDiffToReferenceCommitFor: aView ]
]

{ #category : #'*GToolkit4Git' }
IceRepository class >> gtViewHistoryIn: composite [
	<gtClassView>
	GtGitRepositoryRegistryHistory instance isEmpty
		ifTrue: [ ^ composite empty ].
	^ composite forward
		title: 'History';
		tooltip: 'Show historical repository records';
		priority: 50;
		object: [ GtGitRepositoryRegistryHistory instance];
		view: #gtViewRecordsFor:
]

{ #category : #'*GToolkit4Git' }
IceRepository class >> gtViewRegistryIn: composite [
	<gtClassView>
	^ composite columnedList
		title: 'Registry';
		tooltip: 'Show registered repositories';
		priority: 40;
		items: [ self registry sorted: #name ascending];
		column: 'Name' text: #name;
		column: 'Origin' text: [ :each | [ each originUrl ] on: Error do: [ '' ] ]
]

{ #category : #'*GToolkit4Git' }
IceRepository >> initialDefaultBranchName [
	"Return the default branch name used when initializing a new repository.
	Traditionally and when not otherwise configured or specified this is currently 'master'
	though this might change in the future, so this is what we return here.
	Subclasses should override this and consult the init.defaultbranch git config option."

	^ 'master'
]

{ #category : #'*GToolkit4Git' }
IceRepository >> isDirty [
	self subclassResponsibility
]

{ #category : #'*GToolkit4Git' }
IceRepository >> isGitCliRepository [
	^ false
]

{ #category : #'*GToolkit4Git' }
IceRepository >> packages [
	^ self workingCopy packages
]
