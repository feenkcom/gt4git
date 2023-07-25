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
