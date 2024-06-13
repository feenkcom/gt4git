Class {
	#name : #IceGitCliCommitWalk,
	#superclass : #IceAbstractCommitWalk,
	#instVars : [
		'ids'
	],
	#category : #'GToolkit4Git-Libgit-CLI'
}

{ #category : #accessing }
IceGitCliCommitWalk >> commitStream [
	^ (repository commitsFromIds: ids) asAsyncStream
]

{ #category : #walking }
IceGitCliCommitWalk >> commitsDo: aBlock [
	(repository commitsFromIds: ids) do: [ :each | aBlock value: each ]
]

{ #category : #accessing }
IceGitCliCommitWalk >> ensureIds [
	ids ifNil: [ ids := repository revList ]
]

{ #category : #'walk definition' }
IceGitCliCommitWalk >> fromBranch: branch [
	ids := repository revListForBranch: branch
]

{ #category : #'walk definition' }
IceGitCliCommitWalk >> fromCommit: commit [
	ids := repository revListForCommit: commit id
]

{ #category : #'walk definition' }
IceGitCliCommitWalk >> fromTag: tag [
	ids := repository revListForBranch: tag
]

{ #category : #accessing }
IceGitCliCommitWalk >> ids [
	^ids
]

{ #category : #walking }
IceGitCliCommitWalk >> rawResultsDo: aBlock [
	ids do: [ :each | aBlock value: each ]
]

{ #category : #'walk definition' }
IceGitCliCommitWalk >> uptoCommit: commit [
	ids := ids copyWithoutAll: commit newCommitWalk ids asSet.
]
