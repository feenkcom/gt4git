Extension { #name : #LGitRepository }

{ #category : #'*GToolkit4Git' }
LGitRepository >> getDeltasFromHead: aHead options: anLGitDiffOptions into: aDiffPointer [

	| tree |
	
	tree := aHead treeFor: self.
	
	aDiffPointer 
		diffTreeToWorkdir: tree 
		inRepo: self
		options: anLGitDiffOptions.
	
	^ aDiffPointer deltas
]

{ #category : #'*GToolkit4Git' }
LGitRepository >> isDirty [

	| out head |
	out := LGitDiff of: self.
	head := self head.
	out diffTreeToWorkdir: (self revparse: head name) tree inRepo: self.

	^ out numberOfDeltas isZero not
]

{ #category : #'*GToolkit4Git' }
LGitRepository >> status_list_new: out [ 
	^ self ffiCallSafely: #(int git_status_list_new (LGitStatusList out, self, NULL)) options: #()
]

{ #category : #'*GToolkit4Git' }
LGitRepository >> status_list_new: out withOpts: opts [
	^ self ffiCallSafely: #(int git_status_list_new (LGitStatusList* out, LGitRepository self, LGitStatusOptions* opts)) options: #()
]
