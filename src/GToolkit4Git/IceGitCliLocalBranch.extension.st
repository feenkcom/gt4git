Extension { #name : #IceGitCliLocalBranch }

{ #category : #'*GToolkit4Git' }
IceGitCliLocalBranch >> gtPullFrom: aRemote inWorkingCopy: aLepiterWorkingCopy [
	"A copy of the #pullFrom: method to support a Lepiter-aware pull."

	| remoteBranchCommitId remoteCommit|
	repository fetchBranch: self fromRemote: aRemote.
	remoteBranchCommitId := repository
			lookupRemoteBranch: aRemote name , '/' , self name.
	remoteCommit := repository commitFromGitCommit: remoteBranchCommitId.
	aLepiterWorkingCopy mergeCommit: remoteCommit
]
