Extension { #name : #LGitRepository }

{ #category : #'*GToolkit4Git' }
LGitRepository >> getDeltasFromHead: aHead [

	| out |
	out := LGitDiff newPointer autoRelease; repository: self.
	
	out diffTreeToWorkdir: (self revparse: aHead gitRef) tree inRepo: self.
	
	^ out deltas
]

{ #category : #'*GToolkit4Git' }
LGitRepository >> getStatus [

	| out opts |
	out := LGitStatusList of: self.
	opts := LGitStatusOptions new.
	opts statusOptionsInit.
	opts add: LGitStatusOptionEnum git_status_opt_include_untracked.
	opts add: LGitStatusOptionEnum git_status_opt_recurse_untracked_dirs.
	self status_list_new: out withOpts: opts.
	^ (0 to: out size - 1) collect: [ :i | out at: i ]
]

{ #category : #'*GToolkit4Git' }
LGitRepository >> isDirty [

	| out numDiffs head |
	out := LGitDiff newPointer autoRelease; repository: self.
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
