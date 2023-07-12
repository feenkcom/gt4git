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
