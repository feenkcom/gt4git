Extension { #name : #LGitRepository }

{ #category : #'*GToolkit4Git' }
LGitRepository >> getDeltas [

	| out numDiffs |
	out := LGitDiff newPointer autoRelease; repository: self.
	
	out diffTreeToWorkdir: (self revparse: self head basename) tree inRepo: self.
	
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
