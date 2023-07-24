Class {
	#name : #GtIceGitLocalBranch,
	#superclass : #IceLocalBranch,
	#category : #'GToolkit4Git-Libgit-replace'
}

{ #category : #accessing }
GtIceGitLocalBranch >> commit [
	| gitId |
	gitId := repository lookupLocalBranch: self name.
	^ self repository commitFromGitCommit: gitId
]

{ #category : #accessing }
GtIceGitLocalBranch >> hasUpstream [
	self upstreamIfNone: [ ^ false ].
	^ true
]

{ #category : #accessing }
GtIceGitLocalBranch >> upstream [
	^ self upstreamIfNone: [ IceUpstreamNotConfigured signal ]
]

{ #category : #accessing }
GtIceGitLocalBranch >> upstreamIfNone: aBlock [
	| proc upstream |
	proc := repository git.
	proc
		arguments: {'branch'.
				'--list'.
				'--format=%(upstream)'.
				name}.
	proc runAndWait.
	proc isSuccess ifFalse: [ self error: 'git error' ].
	upstream := proc stdout lines first.
	upstream isEmpty ifTrue: [ ^ aBlock value ].
	^ IceGitRemoteBranch named: upstream inRepository: repository
]
