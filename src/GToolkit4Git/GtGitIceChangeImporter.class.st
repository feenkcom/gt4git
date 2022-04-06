Class {
	#name : #GtGitIceChangeImporter,
	#superclass : #IceChangeImporter,
	#category : #'GToolkit4Git-Lepiter'
}

{ #category : #visiting }
GtGitIceChangeImporter >> visitGitChange: anIceGitChange [ 

	| importer |
	importer := GtGitInsideGitChangeImporter new
		path: anIceGitChange path;
		diff: diff;
		version: version;
		yourself.
	importer importOn: parentNode.
]
