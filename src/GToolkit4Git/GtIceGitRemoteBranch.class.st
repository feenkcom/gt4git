Class {
	#name : #GtIceGitRemoteBranch,
	#superclass : #IceRemoteBranch,
	#category : #'GToolkit4Git-Libgit-replace'
}

{ #category : #accessing }
GtIceGitRemoteBranch >> commit [
	| gitId |
	gitId := repository lookupRemoteBranch: self name.
	^ self repository commitFromGitCommit: gitId
]

{ #category : #accessing }
GtIceGitRemoteBranch >> remoteName [
	^ (self fullname substrings: '/') third
]
