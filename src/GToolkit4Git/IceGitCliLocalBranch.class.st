Class {
	#name : #IceGitCliLocalBranch,
	#superclass : #IceLocalBranch,
	#instVars : [
		'commit',
		'upstream'
	],
	#category : #'GToolkit4Git-Libgit-CLI'
}

{ #category : #accessing }
IceGitCliLocalBranch >> commit [
	| gitId |
	commit ifNotNil: [^commit].
	gitId := repository lookupLocalBranch: self name.
	^ commit := self repository commitFromGitCommit: gitId
]

{ #category : #accessing }
IceGitCliLocalBranch >> commit: anIceGitCommit [
	"Update the branch to point to a commit.
	If the branch is HEAD, check it out in disk also."
	
	self = repository head
		ifTrue: [ repository resetCurrentBranchTo: anIceGitCommit id ]
		ifFalse: [ repository setBranch: name to: anIceGitCommit id].
	commit := nil.
]

{ #category : #accessing }
IceGitCliLocalBranch >> fileSystem [
	
	^ self commit fileSystem
]

{ #category : #accessing }
IceGitCliLocalBranch >> gitRef [
	^ self name
]

{ #category : #accessing }
IceGitCliLocalBranch >> gtPullFrom: aRemote inWorkingCopy: aLepiterWorkingCopy [
	"A copy of the #pullFrom: method to support a Lepiter-aware pull."

	| remoteBranchCommitId |
	repository fetchBranch: self fromRemote: aRemote.
	remoteBranchCommitId := repository
			lookupRemoteBranch: aRemote name , '/' , self name.
	commit := repository commitFromGitCommit: remoteBranchCommitId.
	aLepiterWorkingCopy mergeCommit: commit
]

{ #category : #accessing }
IceGitCliLocalBranch >> hasUpstream [
	self upstreamIfNone: [ ^ false ].
	^ true
]

{ #category : #accessing }
IceGitCliLocalBranch >> incomingCommitsFrom: aRemote [
	| remoteBranch |
	remoteBranch := self remoteBranchFor: aRemote ifNone: [ ^ #() ].
	^ remoteBranch newCommitWalk
		uptoCommit: self commit;
		commits
]

{ #category : #accessing }
IceGitCliLocalBranch >> outgoingCommitsTo: aRemote [
	| remoteBranch walk |
	remoteBranch := self
			remoteBranchFor: aRemote
			ifNone: [ ^ self reducedOutgoingCommitsWhenNoRemote ].
	walk := self newCommitWalk.
	walk uptoCommit: remoteBranch.
	^ walk commits
]

{ #category : #'API - remotes' }
IceGitCliLocalBranch >> pushTo: aRemote [
	repository pushBranch: self name to: aRemote name
]

{ #category : #accessing }
IceGitCliLocalBranch >> remoteBranchFor: aRemote ifNone: aBlock [
	| found remoteName |
	remoteName := aRemote name , '/' , self name.
	found := repository lookupRemoteBranch: remoteName ifAbsent: [ nil ].
	^ found
		ifNil: [ aBlock value ]
		ifNotNil: [ repository basicNewRemoteBranchNamed: remoteName ]
]

{ #category : #'as yet unclassified' }
IceGitCliLocalBranch >> setUpstreamIfMissing: aRemote [
	self hasUpstream ifTrue: [ ^ self ].
	self setUpstream: (aRemote remoteBranchNamed: self gitRef)
]

{ #category : #accessing }
IceGitCliLocalBranch >> trackedBranch [
	^ self upstream
]

{ #category : #'API - remotes' }
IceGitCliLocalBranch >> tracksRemoteBranch [
	^ self hasUpstream
]

{ #category : #accessing }
IceGitCliLocalBranch >> upstream [
	^ self upstreamIfNone: [ IceUpstreamNotConfigured signal ]
]

{ #category : #accessing }
IceGitCliLocalBranch >> upstreamIfNone: aBlock [
	| upStreamName lines |
	upstream notNil ifTrue: [^upstream].
	lines := repository runGitWithArgs: {
		'branch'.
		'--list'.
		'--format=%(upstream)'.
		name }.
	upStreamName := lines first.
	upStreamName isEmpty ifTrue: [ ^ aBlock value ].
	^ upstream := IceGitCliRemoteBranch named: upStreamName inRepository: repository
]
