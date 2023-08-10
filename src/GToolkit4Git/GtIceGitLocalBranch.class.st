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
GtIceGitLocalBranch >> incomingCommitsFrom: aRemote [
	| remoteBranch |
	remoteBranch := self remoteBranchFor: aRemote ifNone: [ ^ #() ].
	^ remoteBranch newCommitWalk
		uptoCommit: self commit;
		commits
]

{ #category : #accessing }
GtIceGitLocalBranch >> outgoingCommitsTo: aRemote [
	| remoteBranch walk |
	remoteBranch := repository
			lookupRemoteBranch: aRemote name , '/' , self name
			ifAbsent: [ ^ self reducedOutgoingCommitsWhenNoRemote ].
	walk := self newCommitWalk.
	walk uptoCommit: remoteBranch.
	^ walk commits
]

{ #category : #accessing }
GtIceGitLocalBranch >> remoteBranchFor: aRemote ifNone: aBlock [
	| found |
	found := repository
			lookupRemoteBranch: aRemote name , '/' , self name
			ifAbsent: [ nil ].
	^ found
		ifNil: aBlock value
		ifNotNil: [ repository basicNewRemoteBranchNamed: found name ]
]

{ #category : #accessing }
GtIceGitLocalBranch >> upstream [
	^ self upstreamIfNone: [ IceUpstreamNotConfigured signal ]
]

{ #category : #accessing }
GtIceGitLocalBranch >> upstreamIfNone: aBlock [
	| upstream lines |
	lines := repository
			runGitWithArgs: {'branch'.
					'--list'.
					'--format=%(upstream)'.
					name}.
	upstream := lines first.
	upstream isEmpty ifTrue: [ ^ aBlock value ].
	^ GtIceGitRemoteBranch named: upstream inRepository: repository
]
