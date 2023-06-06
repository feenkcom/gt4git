Extension { #name : #LGitDiff }

{ #category : #'*GToolkit4Git' }
LGitDiff >> diffTreeToWorkdir: tree inRepo: repo [
	self 
		diffTreeToWorkdir: tree 
		inRepo: repo 
		options: LGitDiffOptions defaults
]

{ #category : #'*GToolkit4Git' }
LGitDiff >> diffTreeToWorkdir: tree inRepo: repo options: anLGitDiffOptions [
	self withReturnHandlerDo: [ 
		self 
			diff_tree_to_workdir: tree 
			in_repo: repo 
			opts: anLGitDiffOptions ]
]

{ #category : #'*GToolkit4Git' }
LGitDiff >> diff_tree_to_workdir: tree in_repo: repo opts: opts [
	 
	^ self
		ffiCall:
			#(LGitReturnCodeEnum git_diff_tree_to_workdir_with_index #(LGitDiff * self , LGitRepository repo , LGitTree tree , LGitDiffOptions * opts))
		options: #()
]

{ #category : #'*GToolkit4Git' }
LGitDiff >> gtViewDeltasFor: aView [
	<gtView>
	^ aView forward
		title: 'Deltas';
		priority: 105;
		object: [ self deltas ];
		view: #gtItemsFor:
]

{ #category : #'*GToolkit4Git' }
LGitDiff >> gtViewFilesFor: aView [
	<gtView>
	^ aView forward
		title: 'Files';
		priority: 100;
		object: [ self files ];
		view: #gtItemsFor:
]
