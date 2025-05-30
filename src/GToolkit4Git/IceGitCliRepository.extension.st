Extension { #name : #IceGitCliRepository }

{ #category : #'*GToolkit4Git' }
IceGitCliRepository >> gtConfigFor: composite [
	<gtView>
	^ composite forward
		title: 'Config';
		priority: 40;
		object: [ self config ];
		view: #gtItemsFor:
]

{ #category : #'*GToolkit4Git' }
IceGitCliRepository >> gtRelease [
	super gtRelease.
	commitMap ifNotNil: [ commitMap removeAll ].
	revListMap ifNotNil: [ revListMap removeAll ].
	remoteMap ifNotNil: [ remoteMap removeAll ].
	self clearCaches
]

{ #category : #'*GToolkit4Git' }
IceGitCliRepository >> gtRepositoryDirectoryFor: aView [
	<gtView>
	
	| status |
	self isMissing ifTrue: [ ^ aView empty ].
	
	status := self getStatusByFile.
	^ (self repositoryDirectory gtTreeFor: aView)
		  title: 'Repository directory';
		  priority: 35;
		  column: 'Tracked' translated icon: [ :each | 
			  | relative |
			  relative := (each relativeTo: self repositoryDirectory)
				              pathString.
			  (status includesKey: relative)
				  ifTrue: [ 
					  (status at: relative) = LGitStatusEnum git_status_wt_new
						  ifTrue: [ BrGlamorousIcons close ]
						  ifFalse: [ BrGlamorousIcons accept ] ]
				  ifFalse: [ "exclude directories"
					  each isDirectory
						  ifTrue: [ BrGlamorousIcons empty ]
						  ifFalse: [ BrGlamorousIcons accept ] ] ] width: 50;
		  column: 'Actions' translated stencil: [ :each | 
			  | relative |
			  relative := each relativeTo: self repositoryDirectory.
			  ((status includesKey: relative pathString) and: [ 
					   (status at: relative pathString)
					   = LGitStatusEnum git_status_wt_new ])
				  ifTrue: [ 
					  BrButton new
						  aptitude: BrGlamorousButtonWithIconAptitude;
						  icon: BrGlamorousVectorIcons add;
						  label: 'Add ' , relative pathString;
						  beTinySize;
						  action: [ :_ | 
							  self index
								  addPath: relative;
								  addToGitIndex ] ]
				  ifFalse: [ 
					  BrButton new
						  aptitude: BrGlamorousButtonWithIconAptitude;
						  icon: BrGlamorousVectorIcons remove;
						  label: 'Remove ' , relative pathString;
						  beTinySize;
						  action: [ :_ | 
							  each isDirectory
								  ifTrue: [ self index removeDirectoryFromIndex: relative pathString ]
								  ifFalse: [ self index removeFileFromIndex: relative pathString ] ] ] ];
		  actionButtonIcon: BrGlamorousIcons go
		  tooltip: 'Open in OS'
		  action: [ WebBrowser openOn: self location fullName ];
		  actionButtonIcon: BrGlamorousVectorIcons inspect 
			tooltip: 'Inspect pure git repository' 
			action: [ :element | element phlow spawnObject: (PureGitRepository on: self repositoryDirectory) ]
]

{ #category : #'*GToolkit4Git' }
IceGitCliRepository >> gtStatusFor: aView [
	<gtView>
	
	self isMissing ifTrue: [ ^ aView empty ].
	^ aView columnedTree
		  title: 'File statuses';
		  priority: 10;
		  items: [ 
			  (self getStatusByFile associations groupedBy: [ :each | 
					   each value categoryName ]) associations sort: [ :a | 
					  a key = 'Untracked'
						  ifTrue: [ 0 ]
						  ifFalse: [ 
							  a key = 'Staged'
								  ifTrue: [ 2 ]
								  ifFalse: [ 1 ] ] ] descending ];
		  children: [ :each | 
			  each value isArray
				  ifTrue: [ each value ]
				  ifFalse: [ {  } ] ];
		  column: 'File' text: [ :each | each key ];
		  column: 'Status' text: [ :each | 
			  each value isArray
				  ifTrue: [ '' ]
				  ifFalse: [ each value statusName ] ];
		  expandAll
]

{ #category : #'*GToolkit4Git' }
IceGitCliRepository class >> gtViewGitCallsIn: composite [
	<gtClassView>
	
	^ composite columnedList
		title: 'Git calls';
		priority: 30;
		items: [ 
			( ( (#runGitWithArgs: gtReferences & #gtViewGitCallsIn: gtImplementors not)
					& ('IceGitCliRepository' gtClassMatches | 'GitCliCommitStore' gtClassMatches)) contents
			, 
			{ self >> #contentsOfFile: } )
				 sort: #selector ascending ];
		column: 'Selector' text: [ :each | each selector ];
		column: 'Class' text: [ :each | each methodClass ]
]

{ #category : #'*GToolkit4Git' }
IceGitCliRepository >> initialDefaultBranchName [
	"Return the default branch name used when initializing a new repository.
	Consult the init.defaultbranch git config option and fall back to our superclass' implementation."

	^ self config at: 'init.defaultbranch' ifAbsent: [ super initialDefaultBranchName ]
]

{ #category : #'*GToolkit4Git' }
IceGitCliRepository >> isDirty [
	^ self getStatusByFile notEmpty
]

{ #category : #'*GToolkit4Git' }
IceGitCliRepository >> isGitCliRepository [
	^ true
]
