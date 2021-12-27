Extension { #name : #IceLibgitRepository }

{ #category : #'*GToolkit4Git' }
IceLibgitRepository >> getDeltasForFullDiff [
	"Return the deltas including untracked files.
	This makes it possible to create a full diff of what changed."

	self handleLibgitError: [ 
		^ (self repositoryHandle 
			getDeltasFromHead: self head
			options: (LGitDiffOptions defaults
				prim_flags: (LGitDiffOptionTypeEnum git_diff_include_untracked value 
					bitXor: LGitDiffOptionTypeEnum git_diff_recurse_untracked_dirs value))) 
					collect: [ :delta | 
						GtGitDelta from: delta in: self ] ]
]

{ #category : #'*GToolkit4Git' }
IceLibgitRepository >> getStatusByFile [

	| res |
	res := Dictionary new.

	self repositoryHandle index allFilesStatusDo: [ :path :flags :_ | 
		res at: path put: (LGitStatusEnum fromInteger: flags).
		0 ].

	^ res
]

{ #category : #'*GToolkit4Git' }
IceLibgitRepository >> gtLocalBranchesFor: aView [
	<gtView>
	self isMissing ifTrue: [ ^ aView empty ].
	^ super gtLocalBranchesFor: aView
]

{ #category : #'*GToolkit4Git' }
IceLibgitRepository >> gtRawStatusFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Raw Status';
		priority: 100;
		items: [self getStatusByFile associations];
		column: 'File'
		text: [:each | each key ];
		column: 'Status'
		text: [:each | each value ]
]

{ #category : #'*GToolkit4Git' }
IceLibgitRepository >> gtRemoteBranchesFor: aView [
	<gtView>
	self isMissing ifTrue: [ ^ aView empty ].
	^ super gtRemoteBranchesFor: aView
]

{ #category : #'*GToolkit4Git' }
IceLibgitRepository >> gtRepositoryDirectoryFor: aView [

	<gtView>
	| status |
	status := self getStatusByFile.
	self isMissing ifTrue: [ ^ aView empty ].
	^ (self repositoryDirectory gtItemsFor: aView)
		  title: 'Repository directory' translated;
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
				  ifFalse: [ "exclude parent dir"
					  relative = '..'
						  ifTrue: [ BrGlamorousIcons empty ]
						  ifFalse: [ BrGlamorousIcons accept ] ] ];
		  column: 'Actions' translated stencil: [ :each | 
			  | relative |
			  
			  relative := each relativeTo: self repositoryDirectory.
			  ((status includesKey: relative pathString) and: [ 
					   (status at: relative pathString) = LGitStatusEnum git_status_wt_new ]) 
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
					ifFalse: [ BrGlamorousIcons empty asElement ] ];
		  actionButtonIcon: BrGlamorousIcons go
		  tooltip: 'Open in OS'
		  action: [ WebBrowser openOn: self location fullName ]
]

{ #category : #'*GToolkit4Git' }
IceLibgitRepository >> gtStatusFor: aView [

	<gtView>
	^ aView columnedTree
		  title: 'Status';
		  priority: 2;
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
IceLibgitRepository >> gtTagsFor: aView [
	<gtView>
	self isMissing ifTrue: [ ^ aView empty ].
	^ super gtTagsFor: aView
]

{ #category : #'*GToolkit4Git' }
IceLibgitRepository >> isDirty [

	^ handle ifNil: [ false ] ifNotNil: [ handle isDirty ]
]
