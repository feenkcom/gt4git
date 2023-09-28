Class {
	#name : #GtIceGitLocalBranch,
	#superclass : #IceLocalBranch,
	#instVars : [
		'commit',
		'upstream'
	],
	#category : #'GToolkit4Git-Libgit-replace'
}

{ #category : #accessing }
GtIceGitLocalBranch >> commit [
	| gitId |
	commit ifNotNil: [^commit].
	gitId := repository lookupLocalBranch: self name.
	^ commit := self repository commitFromGitCommit: gitId
]

{ #category : #'as yet unclassified' }
GtIceGitLocalBranch >> fileSystem [
	
	^ self commit fileSystem
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
	remoteBranch := self
			remoteBranchFor: aRemote
			ifNone: [ ^ self reducedOutgoingCommitsWhenNoRemote ].
	walk := self newCommitWalk.
	walk uptoCommit: remoteBranch.
	^ walk commits
]

{ #category : #'API - remotes' }
GtIceGitLocalBranch >> pushTo: aRemote [
	repository pushBranch: self name to: aRemote name
]

{ #category : #accessing }
GtIceGitLocalBranch >> remoteBranchFor: aRemote ifNone: aBlock [
	| found remoteName |
	remoteName := aRemote name , '/' , self name.
	found := repository lookupRemoteBranch: remoteName ifAbsent: [ nil ].
	^ found
		ifNil: [ aBlock value ]
		ifNotNil: [ repository basicNewRemoteBranchNamed: remoteName ]
]

{ #category : #accessing }
GtIceGitLocalBranch >> upstream [
	^ self upstreamIfNone: [ IceUpstreamNotConfigured signal ]
]

{ #category : #accessing }
GtIceGitLocalBranch >> upstreamIfNone: aBlock [
	| upStreamName lines |
	upstream notNil ifTrue: [^upstream].
	lines := repository
			runGitWithArgs: {'branch'.
					'--list'.
					'--format=%(upstream)'.
					name}.
	upStreamName := lines first.
	upStreamName isEmpty ifTrue: [ ^ aBlock value ].
	^ upstream := GtIceGitRemoteBranch named: upStreamName inRepository: repository
]
