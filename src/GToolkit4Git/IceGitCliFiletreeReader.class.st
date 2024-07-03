Class {
	#name : #IceGitCliFiletreeReader,
	#superclass : #IceLibgitFiletreeReader,
	#category : #'GToolkit4Git-Libgit-CLI'
}

{ #category : #accessing }
IceGitCliFiletreeReader >> fileUtils [
	^ IceGitCliFiletreeFileUtils
]
