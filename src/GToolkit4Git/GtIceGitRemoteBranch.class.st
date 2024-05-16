Class {
	#name : #GtIceGitRemoteBranch,
	#superclass : #IceRemoteBranch,
	#instVars : [
		'commit'
	],
	#category : #'GToolkit4Git-Libgit-CLI'
}

{ #category : #accessing }
GtIceGitRemoteBranch >> commit [
	| gitId |
	commit ifNotNil: [ ^ commit ].
	gitId := repository lookupRemoteBranch: self name.
	^ commit := self repository commitFromGitCommit: gitId
]

{ #category : #accessing }
GtIceGitRemoteBranch >> name [
	^ self fullname withoutPrefix: self prefix
]

{ #category : #accessing }
GtIceGitRemoteBranch >> prefix [
	^ 'refs/remotes/'
]

{ #category : #accessing }
GtIceGitRemoteBranch >> remoteName [
	^ (self fullname substrings: '/') third
]
